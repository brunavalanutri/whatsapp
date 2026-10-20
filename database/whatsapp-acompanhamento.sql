-- Estrutura inicial do acompanhamento de conversas do WhatsApp.
-- Usa o cadastro existente em public.pacientes; não duplica pacientes.
create table if not exists public.whatsapp_conversas (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references public.pacientes(id) on delete cascade,
  nome_arquivo text,
  importada_em timestamptz not null default now(),
  inicio_mensagens timestamptz,
  fim_mensagens timestamptz,
  resumo text not null default '',
  observacoes_nutri text not null default '',
  rascunho_resposta text not null default '',
  criado_por uuid default auth.uid(),
  criado_em timestamptz not null default now()
);

create index if not exists whatsapp_conversas_paciente_data
  on public.whatsapp_conversas (paciente_id, importada_em desc);

create table if not exists public.whatsapp_mensagens (
  id uuid primary key default gen_random_uuid(),
  conversa_id uuid not null references public.whatsapp_conversas(id) on delete cascade,
  data_mensagem timestamptz,
  remetente text not null default 'outro' check (remetente in ('paciente','nutri','outro')),
  nome_remetente text not null default '',
  conteudo text not null,
  ordem integer not null,
  criado_em timestamptz not null default now(),
  unique (conversa_id, ordem)
);

create index if not exists whatsapp_mensagens_conversa_ordem
  on public.whatsapp_mensagens (conversa_id, ordem);

create table if not exists public.whatsapp_tarefas (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references public.pacientes(id) on delete cascade,
  conversa_id uuid references public.whatsapp_conversas(id) on delete set null,
  titulo text not null,
  descricao text not null default '',
  data_prevista date,
  status text not null default 'pendente' check (status in ('pendente','concluida','cancelada')),
  criado_por uuid default auth.uid(),
  criado_em timestamptz not null default now(),
  concluida_em timestamptz
);

create index if not exists whatsapp_tarefas_status_data
  on public.whatsapp_tarefas (status, data_prevista);

create index if not exists whatsapp_tarefas_paciente
  on public.whatsapp_tarefas (paciente_id, criado_em desc);

alter table public.whatsapp_conversas enable row level security;
alter table public.whatsapp_mensagens enable row level security;
alter table public.whatsapp_tarefas enable row level security;

revoke all on public.whatsapp_conversas from anon, public;
revoke all on public.whatsapp_mensagens from anon, public;
revoke all on public.whatsapp_tarefas from anon, public;

grant select, insert, update, delete on public.whatsapp_conversas to authenticated;
grant select, insert, update, delete on public.whatsapp_mensagens to authenticated;
grant select, insert, update, delete on public.whatsapp_tarefas to authenticated;

drop policy if exists whatsapp_conversas_nutri on public.whatsapp_conversas;
create policy whatsapp_conversas_nutri on public.whatsapp_conversas
  for all to authenticated using ((select public.is_nutri()))
  with check ((select public.is_nutri()));

drop policy if exists whatsapp_mensagens_nutri on public.whatsapp_mensagens;
create policy whatsapp_mensagens_nutri on public.whatsapp_mensagens
  for all to authenticated using (
    (select public.is_nutri()) and exists (
      select 1 from public.whatsapp_conversas c where c.id = conversa_id
    )
  )
  with check (
    (select public.is_nutri()) and exists (
      select 1 from public.whatsapp_conversas c where c.id = conversa_id
    )
  );

drop policy if exists whatsapp_tarefas_nutri on public.whatsapp_tarefas;
create policy whatsapp_tarefas_nutri on public.whatsapp_tarefas
  for all to authenticated using ((select public.is_nutri()))
  with check ((select public.is_nutri()));

comment on table public.whatsapp_conversas is 'Importações e notas de acompanhamento de conversas do WhatsApp; acesso exclusivo à nutricionista.';
comment on table public.whatsapp_mensagens is 'Mensagens importadas manualmente de exportações do WhatsApp.';
comment on table public.whatsapp_tarefas is 'Lembretes de contato e tarefas de acompanhamento relacionados a pacientes.';
