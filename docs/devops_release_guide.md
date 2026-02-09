# ScanNutPlus DevOps Release Guide

Este guia descreve como configurar e utilizar o pipeline de release automatizado para o ScanNutPlus.

## 1. Visão Geral
O pipeline é executado via **GitHub Actions** e é acionado automaticamente quando uma nova **TAG** de versão é enviada para o repositório.

**O que ele faz:**
1. Compila o código Flutter para Android (APK Release).
2. Assina o APK usando a Keystore configurada nos Secrets.
3. Cria uma Release no GitHub.
4. Anexa o APK gerado à Release.
5. Gera notas de lançamento automáticas.

## 2. Configuração de Secrets (Única Vez)
Para que o GitHub possa assinar o APK, você precisa configurar as chaves de segurança (Secrets) no repositório.

Vá em: **Settings > Secrets and variables > Actions > New repository secret**

Adicione as seguintes variáveis:

| Nome | Descrição | Como Gerar |
|------|-----------|------------|
| `ANDROID_KEYSTORE_BASE64` | O arquivo `.jks` codificado em Base64. | **Windows (PowerShell):**<br>`[Convert]::ToBase64String([IO.File]::ReadAllBytes("sua-chave.jks")) \| Set-Clipboard`<br><br>**Linux/Mac:**<br>`openssl base64 -in sua-chave.jks \| tr -d '\n' \| pbcopy` |
| `KEYSTORE_PASSWORD` | A senha do arquivo da Keystore. | Senha definida na criação. |
| `KEY_ALIAS` | O alias da chave dentro da Keystore. | Alias definido na criação (ex: `key0`). |
| `KEY_PASSWORD` | A senha individual da chave (alias). | Normalmente a mesma da Keystore. |

## 3. Como Gerar uma Release
O processo é controlado inteiramente via Git Tags, seguindo o padrão [SemVer](https://semver.org/).

### Passo a Passo:

1. **Garanta que o código está pronto e na branch `main`.**
2. **Atualize a versão no `pubspec.yaml`** (opcional, mas recomendado para consistência interna).
3. **Crie e suba a tag:**

```bash
# Para uma versão final (Produção)
git tag v1.0.0
git push origin v1.0.0

# Para uma versão Beta (Pré-release)
git tag v1.1.0-beta.1
git push origin v1.1.0-beta.1
```

### O que acontece depois?
- Vá para a aba **Actions** no GitHub.
- Você verá o workflow **Android Release** rodando.
- Quando terminar (aprox. 5-10 min), vá para a aba **Releases**.
- A nova versão estará lá com o APK pronto para download.
- Se a tag tiver `-beta` ou `-rc`, ela será marcada automaticamente como "Pre-release".

## 4. Estrutura de Branches (Recomendada)
- `main`: Código estável (Produção).
- `develop`: Desenvolvimento contínuo.
- `feature/*`: Novas funcionalidades.

**Fluxo Ideal:**
1. Merge de `develop` -> `main`.
2. Teste final.
3. Tag na `main` -> Release automático.
