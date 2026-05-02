# !! Marker Syntax by Language

Markers use the native comment syntax of the file, prefixed with `!!`.
Place on the line above or beside the target code.

## Python / Nushell / Shell

```python
# !! rename this to process_batch
def handle_items(items):
    pass
```

```nu
# !! switch to par-each for parallel execution
$data | each { |row| process $row }
```

## JavaScript / TypeScript

```js
// !! extract into a separate validate() function
if (input.length > 0 && input.match(/^[a-z]+$/)) {
```

## Rust / Go / C

```rust
// !! this panics on empty input — return Result instead
fn parse(input: &str) -> Value {
```

## HTML / XML / SVG

```html
<!-- !! add aria-label for accessibility -->
<button class="submit">Go</button>
```

## CSS / SCSS

```css
/* !! use a CSS variable instead of hardcoded color */
.header { background: #1a1a2e; }
```

## SQL

```sql
-- !! add index on user_id, this query is slow
SELECT * FROM orders WHERE user_id = ?;
```

## YAML / TOML

```yaml
# !! bump to 3.12 — we need the new match syntax
python_version: "3.10"
```

## Markdown

```markdown
<!-- !! rewrite this section — it describes the old API -->
## Authentication
Send a token in the header...
```

## [keep] modifier

Any marker containing `[keep]` is preserved after processing:

```python
# !! [keep] this function is intentionally duplicated — do not deduplicate
def legacy_handler():
    pass
```

## Commit message examples

```
gi:
```
Process all markers, no global instruction.

```
gi: refactor for readability
```
Process markers AND apply "refactor for readability" globally.

```
add error handling to parser

the CLI crashes on malformed input, need to handle gracefully
```
Plain message (no `gi:` prefix) — if files contain `!!` markers, they are still processed; the message is context.
