````markdown
---
title: "🧹 Script de Limpeza e Otimização do Windows"
description: "Script PowerShell automatizado para remoção de bloatware Dell e aplicativos desnecessários do Windows 10/11, com modo de teste, logs coloridos e desinstalação inteligente."
author: "Gabriel Yan"
website: "https://gabrielyandev.com.br"
instagram: "@gabrielyandev"
license: "MIT"
version: "1.0.0"
last_updated: "08/10/2025"
tags:
  - PowerShell
  - Windows
  - Bloatware
  - Otimização
  - Automação
---

# 🧹 Script de Limpeza e Otimização do Windows

**Script PowerShell para remoção de bloatware Dell e aplicativos desnecessários do Windows**

---

## 📋 Descrição

Script PowerShell automatizado que remove bloatware, aplicativos desnecessários pré-instalados no Windows e otimiza o sistema para melhor performance e experiência do usuário.

---

## ⚠️ Avisos Importantes

🚨 **EXECUTE POR SUA CONTA E RISCO!**

- Sempre teste antes em modo de simulação
- Faça **backup** do seu sistema
- Alguns aplicativos **não podem ser recuperados facilmente**

**Desenvolvido por [Gabriel Yan](https://gabrielyandev.com.br)**

---

## ✨ Funcionalidades

### 🔧 Remoção de Bloatware Dell

- SupportAssist e ferramentas de diagnóstico
- Otimizadores e gerenciadores de energia
- Aplicativos de atualização e driver
- Software de periféricos

### 🗑️ Limpeza de Windows Bloatware

- Aplicativos de jogos (Xbox, Solitaire)
- Ferramentas de comunicação (Skype, Your Phone)
- Aplicativos de mídia (Zune, Groove)
- Redes sociais (Facebook, Twitter, Instagram)

### 🌐 Remoção Multi-idioma

- **Microsoft 365:** en-us, es-es, fr-fr
- **Microsoft OneNote:** en-us, es-es, fr-fr, pt-br
- Suporte a curingas para outros idiomas

### ⚡ Ativação Automática

- Ativação do Windows e Office integrada
- Usa serviço confiável [Activated.win](https://activated.win)

---

## 🛠️ Como Usar

### 1. Pré-requisitos

```powershell
# Execute como Administrador
# PowerShell 5.0 ou superior
# Windows 10/11
```
````

### 2. Execução Básica

```powershell
# 1. Baixe o script
# 2. Clique direito -> "Executar com PowerShell"
# 3. Ou execute via terminal:
.\script_limpeza.ps1
```

### 3. Modo de Teste (RECOMENDADO)

O script perguntará automaticamente:

```
"Deseja executar em modo de teste (WhatIf) primeiro? (S/N)"
```

- **Resposta:** `S` – Mostrará tudo que _seria removido_ sem alterações reais

### 4. Execução Real

Após testar, execute novamente e selecione:

```
"Deseja executar em modo de teste (WhatIf) primeiro? (S/N)" → N
"Tem certeza que deseja continuar? (S/N)" → S
```

---

## 📦 Aplicativos Removidos

### 🔧 Aplicativos Dell

- Dell SupportAssist
- Dell Digital Delivery Services
- Dell Optimizer Core
- Dell Peripheral Manager
- Dell Command | Update
- Dell Display Manager 2.1
- Dell Core Services
- Dell Trusted Device Agent
- Dell Update

### 🎮 Aplicativos de Jogos e Entretenimento

- Microsoft.GamingApp
- Microsoft.Xbox\*
- Microsoft.MicrosoftSolitaireCollection
- Microsoft.ZuneMusic
- Microsoft.ZuneVideo

### 💬 Comunicação

- Microsoft.SkypeApp
- Microsoft.Messaging
- Microsoft.YourPhone

### 📊 Produtividade e Office

- Microsoft.MicrosoftOfficeHub
- Microsoft.Microsoft365\*
- Microsoft.OneNote\*
- Microsoft.GetHelp
- Microsoft.Getstarted
- Microsoft.People
- Microsoft.Bing\*

### 🌐 Microsoft 365 (Multi-idioma)

- Microsoft 365 - en-us
- Microsoft 365 - es-es
- Microsoft 365 - fr-fr
- Microsoft 365 - \*

### 📝 OneNote (Multi-idioma)

- Microsoft OneNote - en-us
- Microsoft OneNote - es-es
- Microsoft OneNote - fr-fr
- Microsoft OneNote - \*

### 🔧 Utilitários Diversos

- Microsoft.OneConnect
- Microsoft.Wallet
- Microsoft.WindowsFeedbackHub
- Microsoft.Paint
- Microsoft.WindowsMaps
- Microsoft.ScreenSketch
- Microsoft.StickyNotes

### 📰 Notícias e Clima

- Microsoft.BingNews
- Microsoft.BingWeather

### 🌐 Redes Sociais

- Facebook\*
- Twitter\*
- Instagram\*

### 🎵 Streaming e Mídia

- Spotify
- Netflix
- Disney+
- Prime Video
- TikTok

---

## ⚙️ Requisitos do Sistema

- Windows 10 ou Windows 11
- PowerShell 5.0 ou superior
- Privilégios de Administrador
- Execution Policy: Bypass (configurado automaticamente)

---

## 🔧 Funcionalidades Técnicas

### 🔍 Busca Avançada

- Procura em múltiplos locais do registro (HKLM, HKCU)
- Suporte a caracteres curinga nos nomes
- Remove duplicatas automaticamente
- Detecta automaticamente tipo de instalador (MSI/EXE)

### 🛡️ Modo Seguro

- Modo WhatIf integrado para testes
- Confirmações em cada etapa crítica
- Verificação de privilégios de administrador
- Log detalhado e colorido de todas as operações

### ⚡ Desinstalação Inteligente

- **MSI:** Usa `msiexec` com parâmetros silenciosos
- **EXE:** Adiciona flags silenciosas automaticamente
- **Appx:** Remove para todos os usuários e desprovisiona

---

## 🎨 Códigos de Cores

| Cor         | Significado                 |
| ----------- | --------------------------- |
| 🟢 Verde    | Operações bem-sucedidas     |
| 🟡 Amarelo  | Avisos e informações        |
| 🔴 Vermelho | Erros e alertas importantes |
| 🟣 Magenta  | Modo de teste               |
| 🔵 Ciano    | Informações detalhadas      |

---

## 👨‍💻 Desenvolvedor

**Gabriel Yan**
-- [gabrielyandev.com.br](https://gabrielyandev.com.br)
-- [@gabrielyandev](https://instagram.com/gabrielyandev)

---

## 📝 Notas Finais

### 🔄 Pós-execução

- Alguns aplicativos podem requerer reinicialização para remoção completa
- Aplicativos essenciais do sistema **não serão removidos**
- É possível reinstalar aplicativos da Microsoft Store se necessário

### 💡 Dicas Importantes

- Sempre execute em **modo de teste primeiro**
- Faça **backup** do sistema antes da execução real
- Verifique a lista de aplicativos que serão removidos
- Alguns aplicativos Dell podem ser úteis para seu hardware

### ⚠️ Limitações Conhecidas

- Alguns aplicativos podem deixar resíduos no registro
- Aplicativos de sistema críticos são protegidos
- Pode ser necessário reiniciar para completar algumas desinstalações

---

## 💡 Dica Final

> Execute sempre em modo de teste primeiro para verificar exatamente quais aplicativos serão afetados antes de prosseguir com a remoção real!

---

**DESENVOLVIDO POR [GABRIEL YAN](https://gabrielyandev.com.br) — [@gabrielyandev](https://instagram.com/gabrielyandev)**

```

```
