# WhatsApp — Acompanhamento Nutricional

Aplicativo interno para organizar o acompanhamento de pacientes por meio de conversas exportadas manualmente do WhatsApp Business.

## Objetivo

Centralizar o histórico de conversas, observações e lembretes de contato, facilitando o acompanhamento nutricional e a continuidade do atendimento.

## Funcionalidades previstas

- Acesso restrito à nutricionista.
- Busca de pacientes cadastrados.
- Importação manual de conversas exportadas do WhatsApp (`.txt`).
- Visualização e organização do histórico de conversas.
- Registro de resumos e observações.
- Campo para rascunhos de respostas.
- Criação de lembretes para entrar em contato com pacientes.

## Tecnologias

- HTML, CSS e JavaScript.
- Supabase para autenticação e armazenamento de dados.
- GitHub para versionamento do código.
- Vercel para hospedagem.

## Privacidade e segurança

O aplicativo não acessa automaticamente as mensagens do WhatsApp e não envia mensagens. A importação é realizada manualmente pela nutricionista.

O acesso aos dados deve ser restrito e protegido por autenticação e políticas de segurança do Supabase.

## Status

Em desenvolvimento. A integração com o banco de dados e os testes serão realizados antes da publicação.

## Observação

Este projeto é independente do aplicativo principal de acompanhamento nutricional, embora possa compartilhar o banco de dados Supabase autorizado.
