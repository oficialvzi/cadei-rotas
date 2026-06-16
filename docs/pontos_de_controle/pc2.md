![bandeira da unb](/docs/assets/bandeira_unb.png)
# ENE0450 - PROJETO INTEGRADOR DE FUNDAMENTOS - Prof. Edson Mintsu

**Integrantes do Grupo**

- Arthur Choi Braga - 242014300
- Eduardo Flor Ocampo - 242014328
- Matheus Cunha de Freitas - 242014355
- Ruan Dias Alves Teixeira - 242014471
- Yago de Oliveira Araújo - 251032138

**Documentação do projeto:**
[Link do repositório GitHub](https://github.com/oficialvzi/cadei-rotas)

# Ponto de Controle 2
## 1. Introdução
 
Este documento apresenta os resultados alcançados na segunda fase de desenvolvimento do projeto **Cadei-Rotas**, aplicativo móvel voltado ao mapeamento colaborativo de acessibilidade para cadeirantes no campus da Faculdade de Tecnologia (FT) da Universidade de Brasília.
 
Desde o Ponto de Controle 1, nós saímos da fase de concepção e documentação para a **implementação funcional dos subsistemas**. Além de relatar o estado atual do produto, este documento detalha as **adequações realizadas no projeto** que impactaram a especificação de componentes, algoritmos e fluxos da solução, apresentando os argumentos técnicos que fundamentaram cada decisão.
 
## 2. Adequações Realizadas no Projeto
 
Durante o desenvolvimento da Sprint, revisamos partes das especificações definidas no PC1. As mudanças a seguir resultaram tanto do feedback recebido quanto de restrições técnicas e da busca por uma solução mais robusta e viável dentro do escopo da disciplina. Cada adequação é apresentada com sua motivação e seu impacto na arquitetura.
 
### 2.1. Remoção da validação de imagens por Inteligência Artificial
 
**Decisão anterior (PC1):** o sistema previa uma *Firebase Cloud Function* que, ao receber um novo report, enviaria a foto e a descrição para uma API de IA, que retornaria um status de "Validada" ou "Não Validada". Apenas reports validados pela IA apareceriam no mapa.
 
**Adequação:** a verificação automática por IA foi **descartada**, ao menos nesta etapa do projeto. O sistema passa a não realizar verificação de conteúdo das imagens enviadas.
 
**Justificativa:** a abordagem por IA introduzia uma complexidade desproporcional ao escopo e ao prazo da disciplina. Ela exigia o uso de *Cloud Functions* no plano pago do Firebase (Blaze), a integração e o custo de uma API de visão computacional externa, e o tratamento de uma série de casos de erro (falsos positivos e negativos) que comprometeriam a confiabilidade da validação. Além disso, delegar a uma IA a decisão sobre a veracidade de uma barreira de acessibilidade levanta questões de confiabilidade que não poderiam ser adequadamente endereçadas no tempo disponível. A equipe optou por substituir essa validação automática por um **mecanismo de validação comunitária** (descrito no item 2.3), mais alinhado à natureza colaborativa (*crowdsourcing*) do produto.
 
**Impacto na arquitetura:** elimina-se o subsistema de *Cloud Functions* e a dependência de API externa de IA. O campo `status` dos reports, que antes seria controlado pela IA, passa a ser governado pela lógica de credibilidade comunitária.
 
### 2.2. Definição das categorias de pins e subcategorias do pin parcial
 
**Decisão anterior (PC1):** a documentação tratava genericamente de "pins positivos e negativos", sem um modelo consolidado de categorias.
 
**Adequação:** consolidou-se um modelo de **três categorias** de pins, identificadas por cor:
 
- **Azul — Acessível:** locais com infraestrutura adequada (rampas, elevadores, banheiros adaptados).
- **Laranja — Parcialmente inacessível:** locais que permitem passagem, mas com dificuldade.
- **Vermelho — Totalmente inacessível:** locais com passagem bloqueada.
Adicionalmente, o **pin laranja (parcial) recebeu subcategorias** que detalham a natureza da dificuldade, como *"não passa cadeira manual"*, *"não passa cadeira elétrica"* e *"rampa com inclinação fora da norma"*.
 
**Justificativa:** a distinção binária entre "acessível" e "inacessível" não refletia a realidade do campus, onde muitos pontos são transitáveis sob certas condições. A introdução da categoria intermediária com subcategorias oferece ao usuário cadeirante uma informação muito mais precisa e acionável — um usuário de cadeira manual e um de cadeira elétrica têm necessidades distintas, e o app agora consegue diferenciar esses casos. Essa granularidade está diretamente alinhada à norma NBR 9050, que trata de diferentes parâmetros de acessibilidade.
 
**Impacto na arquitetura:** o modelo de dados dos pins passou a conter os campos `categoria` e `subcategoria`. A camada de apresentação renderiza marcadores com cores distintas conforme a categoria, e o formulário de report exibe dinamicamente as subcategorias quando a opção "parcial" é selecionada.
 
### 2.3. Reports por usuários não cadastrados e sistema de credibilidade
 
**Decisão anterior (PC1):** o requisito RF06 estabelecia que apenas **usuários autenticados** poderiam registrar denúncias.
 
**Adequação:** o sistema passa a permitir que **usuários não cadastrados também façam reports**. Contudo, esses reports possuem **menor credibilidade**: o report de um usuário não cadastrado tem peso reduzido, exigindo um número maior de relatos independentes para que o pin seja efetivado no mapa, enquanto o report de um usuário cadastrado tem peso integral.
 
**Justificativa:** exigir cadastro como pré-requisito para qualquer contribuição cria uma barreira que reduz drasticamente o volume de dados colaborativos — o oposto do que um sistema de *crowdsourcing* precisa para funcionar. Ao permitir contribuições anônimas, amplia-se a base de colaboradores. O sistema de credibilidade diferenciada resolve o problema de confiança que isso introduz: contribuições anônimas são aceitas, mas exigem corroboração de múltiplos relatos antes de afetar o mapa, ao passo que usuários identificados (mais responsabilizáveis) têm impacto imediato. *Esse mecanismo substitui, de forma mais simples e robusta, a validação por IA que foi descartada.*
 
**Impacto na arquitetura:** o subsistema de autenticação passou a incluir o login anônimo do Firebase Authentication, que atribui um identificador único a cada dispositivo não cadastrado — necessário para contabilizar relatos distintos e impedir votos duplicados. O modelo de dados de reports inclui campos para distinguir e contabilizar relatos de usuários cadastrados e anônimos.
 
> **Observação sobre o estado atual:** o mecanismo de credibilidade está **especificado e modelado**, mas, para fins de demonstração do PC2, encontra-se temporariamente desativado — atualmente todo report cria um pin imediatamente visível no mapa. A ativação da regra de efetivação por limiar está prevista para a próxima Sprint.
 
### 2.4. Adoção do Firebase Storage para armazenamento de imagens
 
**Decisão anterior (PC1):** o armazenamento das fotos seria feito no Firebase Storage, conforme atribuição do Desenvolvedor Backend 1.
 
**Adequação:** confirmou-se o uso do **Firebase Storage** como solução de armazenamento de imagens, após a equipe avaliar e descartar alternativas (como Cloudinary) que haviam sido consideradas diante da exigência de plano pago para o Storage.
 
**Justificativa:** durante o desenvolvimento, identificou-se que o Firebase Storage passou a exigir o plano Blaze (pagamento por utilização). A equipe avaliou serviços externos gratuitos como contingência, mas optou por manter o Firebase Storage por garantir **coesão arquitetural** — autenticação, banco de dados e armazenamento ficam sob o mesmo ecossistema, com SDK oficial, regras de segurança unificadas e integração direta com o restante do *backend*. O plano Blaze foi configurado com alertas de orçamento para evitar custos inesperados, e o volume de uso do projeto permanece confortavelmente dentro da camada gratuita.
 
**Impacto na arquitetura:** a camada de dados passou a ter duas frentes integradas — o **Cloud Firestore** para dados estruturados dos pins (localização, categoria, descrição) e o **Firebase Storage** para os arquivos de imagem. Cada report com foto armazena a imagem no Storage e persiste a URL pública resultante no documento do Firestore.
 
## 3. Arquitetura Atualizada da Solução
 
A arquitetura mantém o modelo Cliente-Servidor em camadas definido no PC1, agora refletindo as adequações descritas. As tecnologias efetivamente empregadas são:
### Camada de Apresentação (Frontend)
 
- **Tecnologia:** aplicativo móvel desenvolvido em **Flutter** (Dart), multiplataforma.
- **Mapa:** integração com **Google Maps** via pacote `google_maps_flutter`, centralizado na FT.
- **Localização:** pacote `geolocator` para obtenção de GPS em tempo real.
- **Captura de imagem:** pacote `image_picker` para câmera e galeria.
- **Interação:** renderização de pins coloridos por categoria sobre o mapa, com modal de detalhes ao toque e fluxo de criação de report.
### Camada de Lógica e Comunicação (Backend)
 
- **Autenticação:** Firebase Authentication, com três modos — e-mail/senha, Google Sign-In e anônimo (para contribuições sem cadastro).
- **Serviços:** lógica organizada em serviços dedicados (`auth_service`, `reports_service`, `storage_service`) que intermediam a comunicação entre o app e a nuvem.
- **Comunicação:** realizada via SDKs oficiais do Firebase sobre HTTPS, garantindo a segurança dos dados.
### Camada de Dados (Persistência)
 
- **Cloud Firestore:** banco de dados NoSQL com suporte a tipos geográficos (*GeoPoint*), armazenando os pins e seus metadados. Leitura em tempo real via *streams*.
- **Firebase Storage:** armazenamento dos arquivos de imagem dos reports, com geração de URL pública por foto.
- **Separação de dados:** pins fixos de *acessibilidade* (inseridos pela equipe) e pins dinâmicos (reportados pela comunidade) coexistem na mesma coleção, diferenciados por seus metadados.
 
## 4. Demonstração de Funcionamento dos Subsistemas
 
Conforme exigido pelo plano de ensino, todos os subsistemas que compõem a solução foram integrados e estão operacionais. A demonstração contempla:
 
**Subsistema de Autenticação** — login funcional por e-mail/senha e por conta Google (Google Sign-In), com criação de conta, recuperação de senha e logout. A sessão diferencia usuários cadastrados de visitantes, refletindo essa condição na interface (tela de perfil).
 
**Subsistema de Mapa** — mapa interativo centralizado na FT, exibindo a localização do usuário em tempo real e os pins de acessibilidade lidos diretamente do Firestore. Cada categoria é renderizada com cor distinta. Ao tocar em um pin, um painel de detalhes exibe categoria, título, descrição, número de relatos e foto, quando disponível.
 
**Subsistema de Report** — fluxo completo de criação de denúncia: o usuário ativa o modo de seleção, toca no local exato no mapa, preenche o formulário (severidade, subcategoria quando aplicável, título, descrição e foto via câmera ou galeria) e confirma. A imagem é enviada ao Firebase Storage e o pin é persistido no Firestore, aparecendo no mapa em tempo real.
 
**Integração entre subsistemas** — a interface entre as partes está demonstrada de ponta a ponta: a autenticação fornece a identidade usada no report; o mapa fornece as coordenadas; o subsistema de report integra Storage (foto) e Firestore (dados); e o mapa reflete imediatamente o novo dado persistido. O fluxo demonstra a comunicação efetiva entre os componentes previstos na arquitetura.


## 5. Estado Atual e Próximos Passos
 
Ao final desta Sprint, o protótipo encontra-se funcional, com todas as telas implementadas, navegação completa entre elas, autenticação operante, mapa integrado ao banco de dados e fluxo de report com upload de imagem.
 
Estão previstos para as próximas etapas (rumo ao PC3):
 
- **Ativação do sistema de credibilidade** comunitária, com efetivação de pins por limiar de relatos.
- Implementação dos botões de **confirmação e contestação** de pins já existentes, integrados à lógica de credibilidade.
- Substituição dos dados mockados da **tela de perfil** por estatísticas reais consultadas do Firestore.
- Refinamento das **regras de segurança** do Firestore e do Storage para o ambiente de produção.
- Testes de campo no campus, percorrendo trajetos reais para validar a precisão do GPS e a usabilidade.
 
## 6. Landing Page do Produto
 
Foi desenvolvida a *landing page* do produto, apresentando o Cadei-Rotas, seu propósito, suas funcionalidades principais e sua proposta de valor para a comunidade.
 
> [Landing page](https://oficialvzi.github.io/cadei-rotas/)
 
## 7. Conclusão
 
O Ponto de Controle 2 consolidou a transição do Cadei-Rotas da fase de concepção para a de implementação funcional. As adequações realizadas — remoção da validação por IA, definição das categorias e subcategorias de pins, abertura para contribuições não cadastradas com credibilidade diferenciada, e confirmação do Firebase Storage — não representaram desvios do objetivo original, mas refinamentos que tornaram a solução mais viável, robusta e fiel à natureza colaborativa do produto. Todos os subsistemas previstos estão implementados, integrados e demonstráveis, e a documentação reflete as decisões correntes do projeto.