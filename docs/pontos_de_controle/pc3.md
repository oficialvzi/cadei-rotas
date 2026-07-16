# ENE0450 - PROJETO INTEGRADOR DE FUNDAMENTOS

## Ponto de Controle 3 — Resultados Finais

Prof. Edson Mintsu

---

**Integrantes do Grupo**

Arthur Choi Braga - 242014300 *(Project Manager)*

Eduardo Flor Ocampo - 242014328

Matheus Cunha de Freitas - 242014355

Ruan Dias Alves Teixeira - 242014471

Yago de Oliveira Araújo - 251032138

---

**Repositório do projeto:** [github.com/oficialvzi/cadei-rotas](https://github.com/oficialvzi/cadei-rotas)

**Landing page:** [oficialvzi.github.io/cadei-rotas](https://oficialvzi.github.io/cadei-rotas/)

**Vídeo demonstrativo:** *[em processo]*

---

## 1. Introdução

Este documento apresenta os resultados finais do projeto **Cadei-Rotas**, aplicativo móvel de mapeamento colaborativo de acessibilidade para cadeirantes no campus Darcy Ribeiro da Universidade de Brasília. Encerrando o ciclo iniciado nos Pontos de Controle 1 e 2, este relatório descreve o protótipo funcional entregue, os testes de integração realizados, a coerência entre o resultado e o problema originalmente proposto, e as decisões de escopo tomadas ao longo do desenvolvimento.

O produto final é um aplicativo Android completo e operacional, no qual usuários — cadastrados ou não — podem visualizar, reportar e validar colaborativamente pontos de acessibilidade do campus, com um sistema de credibilidade que garante a confiabilidade das informações exibidas.

---

## 2. O Problema e a Coerência da Solução Entregue

### 2.1. O problema original

O campus Darcy Ribeiro, apesar de sua extensão, carece de informação centralizada e confiável sobre acessibilidade para cadeirantes. Rampas mal dimensionadas, portas pesadas, pisos irregulares e obras que bloqueiam passagens são obstáculos que um cadeirante só descobre ao encontrá-los — muitas vezes tendo de refazer trajetos inteiros. O Cadei-Rotas foi proposto para resolver isso por meio de um mapa colaborativo, alimentado pela própria comunidade universitária.

### 2.2. Coerência entre o entregue e o proposto

O protótipo final atende ao objetivo central proposto no PC1: **oferecer aos cadeirantes um mapa confiável e colaborativo dos pontos de acessibilidade do campus**. Todas as funcionalidades essenciais para esse fim foram implementadas e estão operacionais.

Considerando os limites de tempo e de recurso técnico de um projeto acadêmico de um semestre, o escopo foi ajustado de forma consciente ao longo do desenvolvimento. Algumas ideias inicialmente cogitadas foram descartadas ou substituídas por alternativas mais viáveis, sempre preservando o objetivo central. Essas decisões estão detalhadas na seção 4.

Do ponto de vista de **recurso financeiro**, o projeto foi desenvolvido a **custo zero**. Embora o Firebase Storage e a Places API do Google exijam a ativação do plano "pay-as-you-go" (Blaze), o volume de uso do projeto permaneceu integralmente dentro das camadas gratuitas dos serviços, não gerando qualquer cobrança.

---

## 3. Funcionalidades Implementadas

O protótipo final entrega o seguinte conjunto de funcionalidades, todas integradas e funcionais:

**Autenticação de usuários.** Login por e-mail/senha e por conta Google (Google Sign-In), com criação de conta e recuperação de senha. Usuários sem cadastro acessam o app por meio de sessão anônima, podendo contribuir com credibilidade reduzida.

**Mapa interativo.** Mapa do campus via Google Maps, com a localização do usuário em tempo real, botão de recentralização e exibição dos pontos de acessibilidade lidos diretamente do banco de dados.

**Busca de locais.** Campo de busca que combina lugares reais do campus (via Places API do Google, com resultados enviesados para o Darcy Ribeiro) e os pontos já cadastrados no aplicativo, centralizando o mapa e abrindo o ponto selecionado.

**Sistema de reports.** Fluxo completo de denúncia de barreiras: seleção do local por toque no mapa, escolha da categoria (acessível, parcialmente acessível, inacessível) e subcategoria, título, descrição e foto (câmera ou galeria), com upload ao Firebase Storage.

**Categorização por cores e subcategorias.** Três categorias identificadas por cor (azul/acessível, laranja/parcial, vermelho/inacessível), com subcategorias que detalham a natureza da barreira parcial.

**Sistema de credibilidade e validação comunitária.** Cada contribuição possui um peso conforme o tipo de usuário (cadastrado = 1,0; anônimo = 0,34). Pontos com credibilidade insuficiente permanecem pendentes (exibidos translúcidos, com aviso), tornando-se efetivos ao atingir o limiar de confirmação.

**Votação (confirmar/contestar).** Cada usuário pode confirmar ou contestar um ponto, com um voto único por pessoa por ponto (garantido por subcoleção indexada pelo identificador do usuário), incluindo a possibilidade de desfazer ou trocar o voto.

**Arquivamento por contestação.** Pontos cujas contestações superam as confirmações são automaticamente arquivados e removidos do mapa — de forma reversível, preservando o histórico.

**Junção de pontos próximos.** Ao reportar uma barreira a menos de 5 metros de um ponto existente da mesma categoria, a contribuição é somada ao ponto existente em vez de criar duplicata.

**Verificação automática.** Pontos que acumulam ao menos 3 confirmações sem nenhuma contestação recebem automaticamente um selo de "Verificado".

**Perfil do usuário.** Exibição de dados da conta, estatísticas reais de contribuição (reports, confirmações e contestações), links para o repositório do projeto e créditos da equipe.

---

## 4. Adequações de Escopo e Decisões de Engenharia

Ao longo do desenvolvimento, a equipe tomou decisões de escopo fundamentadas na relação custo-benefício e nos limites de tempo. As principais foram:

**Verificação de fotos por IA → verificação comunitária.** A proposta original de validar as imagens dos reports por inteligência artificial foi descartada, por exigir infraestrutura de servidor (Cloud Functions), custo adicional e tratamento de erros que comprometeriam a confiabilidade no prazo disponível. Em seu lugar, adotou-se um sistema de **validação comunitária** (credibilidade + votação + verificação automática), mais alinhado à natureza colaborativa do produto e integralmente funcional.

**Roteamento por grafos.** A ideia de calcular rotas acessíveis ponto a ponto por meio de grafos foi descartada nesta etapa. O foco foi consolidado no mapeamento e na validação colaborativa dos pontos — a base de dados necessária para um roteamento futuro. O roteamento fica registrado como evolução natural do produto.

**Modo escuro.** Avaliado e descartado por não agregar valor essencial ao propósito do app frente ao esforço de adaptar todas as telas.

**Notificações push.** Descartadas por exigirem infraestrutura de servidor (Cloud Functions e Firebase Cloud Messaging), cujo custo e complexidade não se justificavam no escopo do projeto.

Em todos os casos, o descarte foi uma decisão consciente para concentrar o esforço nas funcionalidades essenciais ao objetivo do produto, entregando-as de forma robusta e completa.

---

## 5. Testes de Integração e Funcionamento

O protótipo foi validado por meio de testes em **dispositivos reais e emuladores**, cobrindo tanto o ambiente controlado quanto o uso em campo.

**Testes em campo.** O aplicativo foi testado em dispositivos Android físicos, tanto em ambiente doméstico quanto **percorrendo o próprio campus** — criando reports reais, validando a precisão do GPS, o posicionamento dos pontos no mapa e o upload de fotos em condições reais de uso.

**Cobertura da equipe.** Quatro integrantes testaram o aplicativo em celulares Android físicos, e a equipe completa validou o funcionamento em emuladores. Cada máquina/dispositivo teve sua impressão digital (SHA-1) registrada no Firebase, garantindo que o login com Google funcionasse para todos.

**Bugs encontrados e corrigidos.** Os testes de integração revelaram falhas que foram diagnosticadas e corrigidas, entre elas:

- **Persistência da posição do mapa:** o mapa não preservava a última posição visualizada pelo usuário ao alternar entre telas. O comportamento de câmera foi ajustado para o esperado.
- **Arquivamento indevido de pontos:** uma falha na lógica do sistema de votação fazia com que **qualquer** contestação arquivasse o ponto imediatamente. A regra foi corrigida para arquivar apenas quando as contestações efetivamente superam as confirmações, tornando o sistema resiliente a contestações isoladas ou mal-intencionadas.

A correção desses defeitos, identificados apenas com o teste integrado dos subsistemas, evidencia a importância da fase de validação e resultou em um protótipo final estável.

---

## 6. Arquitetura Final da Solução

A solução final mantém a arquitetura Cliente-Servidor em camadas:

**Camada de Apresentação (Frontend):** aplicativo Android nativo desenvolvido em Flutter (Dart), com Google Maps (`google_maps_flutter`), localização (`geolocator`), captura de imagem (`image_picker`) e busca de lugares (Places API New via HTTP).

**Camada de Lógica (Backend):** serviços dedicados de autenticação, reports e armazenamento, orquestrando a comunicação com a nuvem. A lógica de credibilidade, votação, junção e verificação reside no serviço de reports, executada de forma transacional para garantir a consistência dos dados.

**Camada de Dados (Persistência):** Cloud Firestore para dados estruturados (pontos, votos e estatísticas de usuário, com leitura em tempo real) e Firebase Storage para as imagens dos reports.


---

## 7. Entregáveis Finais

| Entregável | Estado |
|---|---|
| Aplicativo Android funcional (APK) | Concluído |
| Código-fonte no repositório | Concluído e atualizado |
| Documentação técnica (PC1, PC2, PC3) | Concluída |
| Landing page do produto | Concluída — [link](https://oficialvzi.github.io/cadei-rotas/) |
| Vídeo demonstrativo | *[em processo]* |


---

## 8. Conclusão

O Cadei-Rotas cumpre o objetivo proposto no início do projeto: entregar aos cadeirantes do campus Darcy Ribeiro uma ferramenta colaborativa, confiável e funcional para o mapeamento de acessibilidade. Todas as funcionalidades essenciais foram implementadas, integradas e validadas em testes de campo com dispositivos reais.

As adequações de escopo realizadas ao longo do desenvolvimento — como a substituição da validação por IA por um sistema de validação comunitária — não representaram perdas em relação ao objetivo original, mas decisões de engenharia que priorizaram a robustez e a viabilidade dentro dos limites de tempo e recurso do projeto. O resultado é um protótipo maduro, estável e coerente com o problema que se propôs a resolver, desenvolvido integralmente a custo zero.

\

---

*Documento produzido com apoio de ferramentas de inteligência artificial para redação e organização, conforme política da disciplina.*
