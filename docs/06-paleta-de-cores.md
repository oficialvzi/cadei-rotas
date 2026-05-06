# Paleta de Cores — Cadei-Rotas

Sistema de cores oficial do projeto, usado tanto na interface do aplicativo quanto nos diagramas técnicos da documentação.

## Filosofia

A paleta foi desenhada considerando o contexto de acessibilidade e mapeamento:

- **Azul** como cor primária por sua associação internacional com acessibilidade (símbolo ISA desde 1968) e navegação.
- **Verde** como cor secundária para representar "caminho livre" e estados de aprovação.
- **Escala laranja → âmbar → vermelho** para indicar severidade de barreiras reportadas.
- **Roxo** reservado exclusivamente para interações com IA (Gemini).
- **Neutros quentes** (off-white com tom amarelado sutil) para fundos, em vez de cinzas frios — complementam melhor o azul primário.

## Cores Primárias — Azul Acessibilidade

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `azul-rota` | `#0E5FB5` | `14, 95, 181` | Cor da marca, botões primários, header |
| `azul-hover` | `#378ADD` | `55, 138, 221` | Estado hover, elementos ativos |
| `azul-tile` | `#E6F1FB` | `230, 241, 251` | Fundos suaves, cards informativos |

## Cores Secundárias — Verde Caminho Livre

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `verde-acesso` | `#0F6E56` | `15, 110, 86` | Marcadores de pontos acessíveis no mapa |
| `verde-confirmado` | `#1D9E75` | `29, 158, 117` | Sucesso, aprovação da IA |
| `verde-tile` | `#E1F5EE` | `225, 245, 238` | Badges, fundo de mensagens de sucesso |

## Cores Semânticas — Barreiras e Estados

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `laranja-alerta` | `#D85A30` | `216, 90, 48` | Barreira reportada (padrão) |
| `ambar-aviso` | `#BA7517` | `186, 117, 23` | Report em moderação manual |
| `vermelho-bloqueio` | `#A32D2D` | `163, 45, 45` | Passagem totalmente intransitável |
| `roxo-ia` | `#534AB7` | `83, 74, 183` | Indicação de processamento por IA |

## Neutros

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `texto-principal` | `#1A1A1A` | `26, 26, 26` | Títulos, texto de corpo |
| `texto-secundario` | `#5F5E5A` | `95, 94, 90` | Subtítulos, labels, hints |
| `borda` | `#D3D1C7` | `211, 209, 199` | Divisores, bordas de inputs |
| `fundo-card` | `#F5F4EE` | `245, 244, 238` | Surface secundário, cards |
| `branco` | `#FFFFFF` | `255, 255, 255` | Background principal |

## Implementação no Flutter

Crie um arquivo `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primárias
  static const azulRota = Color(0xFF0E5FB5);
  static const azulHover = Color(0xFF378ADD);
  static const azulTile = Color(0xFFE6F1FB);

  // Secundárias
  static const verdeAcesso = Color(0xFF0F6E56);
  static const verdeConfirmado = Color(0xFF1D9E75);
  static const verdeTile = Color(0xFFE1F5EE);

  // Semânticas
  static const laranjaAlerta = Color(0xFFD85A30);
  static const ambarAviso = Color(0xFFBA7517);
  static const vermelhoBloqueio = Color(0xFFA32D2D);
  static const roxoIA = Color(0xFF534AB7);

  // Neutros
  static const textoPrincipal = Color(0xFF1A1A1A);
  static const textoSecundario = Color(0xFF5F5E5A);
  static const borda = Color(0xFFD3D1C7);
  static const fundoCard = Color(0xFFF5F4EE);
  static const branco = Color(0xFFFFFFFF);
}
```

## Acessibilidade — Contraste WCAG

Todas as combinações principais atendem ao mínimo **WCAG AA** (4.5:1 para texto normal, 3:1 para texto grande):

| Combinação | Razão | Nível |
|------------|-------|-------|
| Texto preto (#1A1A1A) sobre branco | 18.9:1 | AAA |
| Branco sobre Azul Rota (#0E5FB5) | 5.8:1 | AA |
| Branco sobre Verde Acesso (#0F6E56) | 5.4:1 | AA |
| Branco sobre Vermelho Bloqueio (#A32D2D) | 6.7:1 | AAA |
| Texto secundário (#5F5E5A) sobre branco | 6.5:1 | AAA |

> Nunca use texto colorido sobre fundo colorido sem testar contraste — o público-alvo do projeto inclui pessoas com baixa visão.

## Aplicação nos Marcadores do Mapa

| Tipo de marcador | Cor de fundo | Ícone |
|------------------|--------------|-------|
| Rampa acessível | `verde-acesso` | ♿ |
| Elevador | `azul-rota` | 🛗 |
| Banheiro acessível | `verde-acesso` | 🚻 |
| Vaga PCD | `azul-rota` | 🅿️ |
| Barreira reportada | `laranja-alerta` | ⚠️ |
| Em moderação | `ambar-aviso` | ⏳ |
| Bloqueio total | `vermelho-bloqueio` | 🚫 |
