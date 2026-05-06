# Identidade Visual — Cadei-Rotas

Documentação da marca: logo, conceito, regras de uso e arquivos.

## Conceito

O nome **Cadei-Rotas** combina dois conceitos centrais: a cadeira de rodas (público-alvo) e as rotas/caminhos (mapeamento). A logo traduz isso em três elementos visuais sobrepostos:

- **Pin de localização** — silhueta externa, vocabulário visual universal de mapas
- **Roda de cadeira** — círculo interno com raios e cubo central
- **Linha de rota** — tracejado verde indicando movimento e caminho acessível

A divisão cromática do nome reforça o conceito: **"Cadei"** em azul (acessibilidade) e **"Rotas"** em verde (caminho livre).

## Versões da Logo

### 1. Logo principal (horizontal)

Arquivo: [`assets/logo-horizontal.svg`](./assets/logo-horizontal.svg)

Uso recomendado:
- Cabeçalho do aplicativo (telas largas, tablets)
- Landing page do produto
- Documentos, apresentações e relatórios
- Materiais de divulgação

Tamanho mínimo: 200px de largura.

### 2. Ícone do app

Arquivo: [`assets/logo-icone.svg`](./assets/logo-icone.svg)

Uso recomendado:
- Launcher icon Android (gerar em 48, 72, 96, 144, 192px)
- App icon iOS (gerar em 60, 76, 120, 152, 1024px)
- Favicon do site
- Avatares e thumbnails

Para Android, exportar em formato PNG nas densidades padrão. Para iOS, gerar todos os tamanhos exigidos pela Apple (1024×1024 como base).

### 3. Versão monocromática

Arquivo: [`assets/logo-mono.svg`](./assets/logo-mono.svg)

Uso recomendado:
- Documentos impressos em preto e branco
- Marca d'água sobre fotos
- Contextos onde cor não está disponível ou apropriada

## Regras de Uso

**O que fazer:**
- Manter área de respiro mínima ao redor da logo (equivalente à altura da letra "C" do wordmark)
- Usar sobre fundos com contraste adequado
- Escalar proporcionalmente (segurar Shift ao redimensionar)

**O que evitar:**
- Distorcer ou esticar a logo
- Alterar as cores fora da paleta oficial
- Aplicar sombras, brilhos ou efeitos decorativos
- Usar a logo principal em tamanhos menores que 200px (use o ícone)
- Sobrepor sobre fundos com baixo contraste ou imagens visualmente ruidosas

## Tipografia

A logo usa fonte sans-serif moderna. Para reprodução em ambientes Flutter, recomenda-se a família **Inter** ou **Roboto** com peso 500 (medium).

```dart
// pubspec.yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Medium.ttf
        weight: 500
```

## Arquivos da Marca

| Arquivo | Formato | Uso |
|---------|---------|-----|
| [`assets/logo-horizontal.svg`](./assets/logo-horizontal.svg) | SVG | Logo principal vetorial |
| [`assets/logo-icone.svg`](./assets/logo-icone.svg) | SVG | Ícone do app vetorial |
| [`assets/logo-mono.svg`](./assets/logo-mono.svg) | SVG | Versão monocromática vetorial |

> **Conversão para PNG:** abra qualquer SVG no [SVGOMG](https://jakearchibald.github.io/svgomg/) para otimizar, e use [CloudConvert](https://cloudconvert.com/svg-to-png) ou o próprio editor (Inkscape, Figma) para exportar em PNG nas resoluções necessárias.

## Paleta de Cores

A paleta completa do projeto está documentada em [`06-paleta-de-cores.md`](./06-paleta-de-cores.md).

Resumo das cores da marca:
- **Azul Rota** (`#0E5FB5`) — cor primária, símbolo
- **Verde Acesso** (`#0F6E56`) — cor secundária, "Rotas"
- **Texto Principal** (`#1A1A1A`) — wordmark
- **Texto Secundário** (`#5F5E5A`) — tagline
