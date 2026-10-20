-- Dashboard de acompanhamento WhatsApp e registro manual da última conversa.
-- Migration idempotente; aplicada ao projeto Supabase APP ACOMPANHAMENTO.

alter table public.whatsapp_conversas alter column paciente_id drop not null;
alter table public.whatsapp_conversas
  add column if not exists contato_nome text,
  add column if not exists categoria text not null default 'paciente',
  add column if not exists eh_grupo boolean not null default false;
alter table public.whatsapp_conversas
  drop constraint if exists whatsapp_conversas_categoria_check;
alter table public.whatsapp_conversas
  add constraint whatsapp_conversas_categoria_check check (categoria in ('paciente','lead'));
create index if not exists whatsapp_conversas_categoria_importada
  on public.whatsapp_conversas (categoria, importada_em desc);

create table if not exists public.whatsapp_paciente_contatos (
  paciente_id uuid primary key references public.pacientes(id) on delete cascade,
  ultima_conversa_em date,
  observacao text not null default '',
  atualizado_por uuid default auth.uid(),
  atualizado_em timestamptz not null default now()
);
alter table public.whatsapp_paciente_contatos enable row level security;
revoke all on public.whatsapp_paciente_contatos from anon, public;
grant select, insert, update, delete on public.whatsapp_paciente_contatos to authenticated;
drop policy if exists whatsapp_paciente_contatos_nutri on public.whatsapp_paciente_contatos;
create policy whatsapp_paciente_contatos_nutri on public.whatsapp_paciente_contatos
 for all to authenticated using ((select public.is_nutri()))
 with check ((select public.is_nutri()));
comment on table public.whatsapp_paciente_contatos is 'Registro manual da última conversa e observações de contato no app WhatsApp; acesso exclusivo à nutricionista.';
