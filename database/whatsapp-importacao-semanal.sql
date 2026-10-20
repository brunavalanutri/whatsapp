-- Atualização para importação semanal em lote e separação entre pacientes e leads.
-- Aplicar uma única vez no projeto Supabase já utilizado pelo app WhatsApp.

alter table public.whatsapp_conversas
  alter column paciente_id drop not null;

alter table public.whatsapp_conversas
  add column if not exists contato_nome text not null default '',
  add column if not exists categoria text not null default 'paciente'
    check (categoria in ('paciente','lead')),
  add column if not exists eh_grupo boolean not null default false;

create index if not exists whatsapp_conversas_categoria_data
  on public.whatsapp_conversas (categoria, importada_em desc);

-- Conversas antigas permanecem como pacientes; registros novos podem ser leads
-- sem paciente_id, mas continuam protegidos pelas policies RLS existentes.
