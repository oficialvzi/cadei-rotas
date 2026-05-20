# Documentação - Cadei-Rotas
Documentação técnica do **Projeto Cadei-Rotas** da disciplina **ENE0450 - Projeto Integrador de Fundamentos** da UnB, semestre 2026/1.

<p align="center">
  <img src="/docs/logo-horizontal.svg" alt="Logo Cadei-Rotas">
</p>


## Sobre o Projeto
O Cadei-Rotas é um aplicativo mobile de acessibilidade utilizando um sistema de mapeamento georreferenciado limitado ao perímetro da UnB. A aplicação integra dados estáticos de infraestruturas acessíveis (rampas, elevadores) a uma interface colaborativa de crowdsourcing que permite aos usuários reportar barreiras arquitetônicas em tempo real, com validação automática de imagens via IA.

## Stack Tecnológica
- **Front-end:** Flutter (Dart)
- **Back-end:** Firebase (Authenticação, Firestore, Armazenamento, Funções da Nuvem)
- **Mapa:** Google Maps via plugin `google_maps_flutter`
- **Inteligência Artificial:** Google Gemini via Firebase AI Logic

## Índice da Documentação
| #   | Documento | Descrição|
| --- | --------- | -------- |
| 01  | [Diagrama de Componentes](./01-diagrama-componentes.md)   | Visão estrutural do sistema e seus módulos |
| 02  | [Diagrama de Casos de Uso](./02-diagrama-casos-de-uso.md) | Funcionalidades disponíveis para cada tipo de usuário |
| 03  | [Jornada do Usuário](./03-jornada-do-usuario.md)          | Fluxos de navegação concretos no aplicativo  |
| 04  | [Diagrama de Sequência](./04-diagrama-sequencia.md)       | Ordem temporal das interações entre componentes |
| 05  | [Roadmap e Cronograma](./05-roadmap-cronograma.md)        | Planejamento das sprints e pontos de controle |
| 05  | [Protótipo de Telas](./06-prototipo-telas.md)        | Protótipo das principais telas do app |


## Como Visualizar os Diagramas
 
Todos os diagramas estão em formato **Mermaid**, renderizado nativamente pelo GitHub. Para outras plataformas:
 
- **Editor online:** cole o código em [mermaid.live](https://mermaid.live) para visualizar e exportar como PNG/SVG.
- **VS Code:** instale a extensão *Markdown Preview Mermaid Support*.
- **Notion/Obsidian:** suportam Mermaid nativamente.