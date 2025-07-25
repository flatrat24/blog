+++
title = "Markdown Showcase"
date = "2025-07-07"
updated = "2025-07-07"
description = "A comprehensive display of how my website renders commonmark"
+++
## Markdown

Text can be **bold**, *italic*, ~~strikethrough~~, and ***~~all at the same time~~***.

[Link to another page](@/blog/shedding_weight.md).

There should be whitespace between paragraphs[^1].

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

This is a normal paragraph[^2] following a header.

😭😂🥺🤣❤️✨🙏😍🥰😊

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

> "Original content is original only for a few seconds before getting old"
> > Rule #21 of the internet

- Item 1
- Item 2
  - Item 2.1
  - Item 2.2
- Item 3
- `Item 4`

1. Perform step #1
2. Proceed to step #2
3. Conclude with step #3

- [ ] Milk
- [x] Eggs
- [x] Flour
- [ ] Coffee
- [x] Combustible lemons

[![Male mallard duck](https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Male_mallard_duck_2.jpg/800px-Male_mallard_duck_2.jpg)](https://upload.wikimedia.org/wikipedia/commons/2/24/Male_mallard_duck_2.jpg)

| Mare         | Rating            | Additional info  |
| :----------- | :---------------- | :--------------- |
| Fluttershy   | Best pone         | Shy and adorable |
| Apple Jack   | Good pone         | Honest and nice  |
| Pinkie Pie   | Fun pone          | Parties and ADHD |
| Twilight     | Main pone         | Neeerd           |
| Rainbow Dash | Yes               | Looks badass     |
| Rarity       | Fancy pone        | Generous         |
| Derpy Hooves | *M u f f i n s*   | [REDACTED]       |

```rust
let highlight = true;
```

```scss, linenos, linenostart=10, hl_lines=3-4 8-9, hide_lines=2 7
pre mark {
  // If you want your highlights to take the full width
  display: block;
  color: currentcolor;
}
pre table td:nth-of-type(1) {
  // Select a colour matching your theme
  color: #6b6b6b;
  font-style: italic;
}
```

[^1]: Footnote
[^2]: [Footnote (link)](https://example.org)
