# Guia de Resubmissão ao CRAN — prLogistic v2.0.0

## Visão geral

Este guia descreve **cada passo**, na ordem certa, para subir o pacote ao
GitHub com pkgdown e em seguida submetê-lo ao CRAN.

---

## PARTE 1 — Publicar no GitHub

### 1.1 Pré-requisitos locais

Instale os pacotes de desenvolvimento uma vez:

```r
install.packages(c("devtools", "roxygen2", "pkgdown", "usethis",
                   "testthat", "knitr", "rmarkdown"))
```

### 1.2 Criar o repositório no GitHub

1. Acesse <https://github.com/new>
2. Nome do repositório: `prLogistic`
3. Visibilidade: **Public**
4. **Não** marque "Add a README" (já temos um)
5. Clique em **Create repository**

### 1.3 Subir o pacote

Extraia o zip `prLogistic_v2.0.0.zip` numa pasta local, depois:

```bash
cd prLogistic/              # pasta raiz do pacote

git init
git add .
git commit -m "feat: v2.0.0 — continuous covariates, GEE, survey, S3 class"
git branch -M main
git remote add origin https://github.com/Raydonal/prLogistic.git
git push -u origin main
```

### 1.4 Ativar GitHub Pages

1. No repositório → **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: `gh-pages` → `/root`
4. Clique em **Save**

O site será publicado automaticamente em
`https://raydonal.github.io/prLogistic/` após o primeiro push
(o GitHub Actions cuida disso).

### 1.5 Regenerar NAMESPACE e documentação

Na pasta do pacote, no R:

```r
library(devtools)
devtools::document()   # roda roxygen2, regenera NAMESPACE e man/
```

Confirme que `NAMESPACE` foi atualizado e que os arquivos `.Rd`
foram criados em `man/`.

---

## PARTE 2 — Verificação local antes do CRAN

### 2.1 R CMD check (deve ter 0 ERRORs e 0 WARNINGs)

```r
devtools::check()
```

Ou na linha de comando:

```bash
R CMD build .
R CMD check prLogistic_2.0.0.tar.gz --as-cran
```

O flag `--as-cran` ativa verificações extras que o CRAN faz.

### 2.2 Checklist do CRAN

Corrija **todos** os itens antes de submeter:

| Item | O que verificar |
|------|----------------|
| 0 ERRORs | `R CMD check --as-cran` |
| 0 WARNINGs | idem |
| NOTEs aceitáveis | "New submission" é OK. "installed size" < 5 MB é OK. |
| `\dontrun{}` nos exemplos demorados | Exemplos com bootstrap (> 5s) devem usar `\dontrun{}` |
| URLs válidas | Todas as URLs em `DESCRIPTION` e `.Rd` devem responder |
| Licença | GPL-2 — já está em `DESCRIPTION` |
| `Authors@R` com roles | `aut` e `cre` já definidos |
| `Date` em `DESCRIPTION` | Manter no formato `YYYY-MM-DD` |
| Título sem "An/A/The" | "Estimation of Prevalence Ratios..." ✓ |
| Título sem nome do pacote | Não repetir "prLogistic" no título ✓ |
| Description com 3+ frases | ✓ já está |
| Vinhetas compilam | `devtools::build_vignettes()` |

### 2.3 Verificar nos três principais sistemas operacionais

Use o serviço **win-builder** do CRAN gratuitamente:

```r
devtools::check_win_devel()    # Windows + R-devel
devtools::check_win_release()  # Windows + R-release
```

E o **macOS builder** via R-hub:

```r
# install.packages("rhub")
rhub::check_for_cran()
```

---

## PARTE 3 — Submissão ao CRAN

### 3.1 Criar o arquivo cNews

Verifique se `NEWS.md` documenta as mudanças da v2.0.0. O CRAN lê isso.

### 3.2 Criar o `cran-comments.md`

Crie este arquivo na raiz do pacote (não é enviado ao CRAN, mas é
boa prática manter):

```markdown
## R CMD check results

0 errors | 0 warnings | 1 note

* New submission (package was archived; this is a resubmission)

## Tested on

* macOS (local): R 4.4.x — 0 errors, 0 warnings, 1 note
* win-builder (R-devel): 0 errors, 0 warnings, 1 note
* win-builder (R-release): 0 errors, 0 warnings, 1 note

## Note about the 1 NOTE

"New submission" — the package was previously on CRAN (v1.2, archived
2013) and this is a resubmission as v2.0.0 with major improvements.
```

### 3.3 Submeter

```r
devtools::submit_cran()
```

Ou manualmente em: <https://cran.r-project.org/submit.html>

**Campos obrigatórios no formulário:**
- Name: Raydonal Ospina
- Email: raydonal@de.ufpe.br
- Upload: `prLogistic_2.0.0.tar.gz`

### 3.4 O que esperar depois

| Etapa | Tempo típico |
|-------|-------------|
| Confirmação automática por e-mail | imediato |
| Verificação automática (win-builder etc.) | 1–2 horas |
| Revisão humana pelo CRAN | 1–7 dias |
| Publicação (se aprovado) | 1–2 dias após aprovação |

---

## PARTE 4 — Se o CRAN pedir correções

É muito comum o CRAN solicitar ajustes. As solicitações mais frequentes são:

### 4.1 "Examples take too long"

Envolva exemplos com bootstrap em `\dontrun{}` ou reduza `R`:

```r
#' @examples
#' \dontrun{
#' res <- prLogisticBootCond(fit, data = birthwt, R = 999)
#' }
```

### 4.2 "Please add \value to all exported functions"

Certifique-se que todas as funções exportadas têm `@return` no roxygen.
Já está feito no v2.0.0.

### 4.3 "Found (possibly) invalid URL"

Teste todas as URLs manualmente. O CRAN verifica literalmente cada `\url{}` e `\doi{}` nos arquivos `.Rd`.

### 4.4 "Package size > 5 MB"

Se os dados comprimidos ficarem grandes:

```r
# Em vez de .rda, usar .rda com compressão máxima
tools::resaveRdaFiles("data/")
```

### 4.5 Resubmissão

Incremente a versão (2.0.1) e adicione entrada no `NEWS.md`:

```markdown
# prLogistic 2.0.1

* Fixed CRAN submission note: wrapped long-running examples in `\dontrun{}`.
```

Depois: `devtools::submit_cran()` novamente.

---

## PARTE 5 — Após aprovação no CRAN

### 5.1 Tag de versão no GitHub

```bash
git tag v2.0.0
git push origin v2.0.0
```

### 5.2 Criar Release no GitHub

1. GitHub → **Releases → Create a new release**
2. Tag: `v2.0.0`
3. Título: "prLogistic v2.0.0"
4. Descrição: copie do `NEWS.md`
5. Anexe o `.tar.gz` como asset

### 5.3 Atualizar os badges no README

Após aprovação, os badges do CRAN ficarão ativos automaticamente:

```markdown
[![CRAN status](https://www.r-pkg.org/badges/version/prLogistic)](https://CRAN.R-project.org/package=prLogistic)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/prLogistic)](https://cran.r-project.org/package=prLogistic)
```

---

## Resumo rápido (fluxo completo)

```
1. devtools::document()           ← regenera NAMESPACE e man/
2. devtools::check()              ← 0 errors, 0 warnings?
3. devtools::check_win_devel()    ← testa no Windows/R-devel
4. git add . && git push          ← sobe ao GitHub, dispara Actions
5. devtools::submit_cran()        ← envia ao CRAN
6. Aguardar e-mail do CRAN        ← 1–7 dias
7. Corrigir se necessário         ← incrementar versão, NEWS.md
8. git tag v2.0.0 && git push --tags
```

---

## Contatos úteis

- CRAN policy: <https://cran.r-project.org/web/packages/policies.html>
- Dúvidas: <cran@r-project.org>
- R-pkg-devel mailing list: <https://stat.ethz.ch/mailman/listinfo/r-package-devel>
