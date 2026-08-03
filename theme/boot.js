import Reveal from "https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/dist/reveal.esm.js";
import Highlight from "https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/plugin/highlight/highlight.esm.js";
import Notes from "https://cdn.jsdelivr.net/npm/reveal.js@5.1.0/plugin/notes/notes.esm.js";
import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs";

mermaid.initialize({
  startOnLoad: false,
  theme: "dark",
  securityLevel: "loose",
  fontFamily: "Helvetica, Arial, sans-serif",
});

const isPrintPdf = /print-pdf/i.test(window.location.search);

async function renderMermaid(root) {
  const nodes = [...(root || document).querySelectorAll(".mermaid:not([data-processed])")];
  if (!nodes.length) return;
  for (const n of nodes) {
    try {
      await mermaid.run({ nodes: [n] });
    } catch (err) {
      console.warn("mermaid", err);
    }
  }
}

window.renderAllMermaidForPrint = () => renderMermaid(document);

const deck = new Reveal({
  hash: true,
  slideNumber: "c/t",
  width: 1280,
  height: 720,
  margin: 0.06,
  plugins: [Highlight, Notes],
});

if (isPrintPdf) {
  document.querySelector(".brand")?.remove();
  document.querySelector(".footer")?.remove();
}

deck.on("ready", (e) => {
  if (isPrintPdf) renderMermaid(document);
  else renderMermaid(e.currentSlide);
});
deck.on("slidechanged", (e) => {
  if (!isPrintPdf) renderMermaid(e.currentSlide);
});
window.addEventListener("beforeprint", () => renderMermaid(document));
deck.initialize();
