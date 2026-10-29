import { codeToTokens, isSupportedLanguage } from '@pierre/highlights';
import languageAliases from '../../node_modules/@pierre/highlights/dist/languages.js';
import * as themeExports from '@pierre/highlights/themes';

const version = '1.0.0';
const themeEntries = Object.entries(themeExports)
  .filter(([, value]) => value && typeof value === 'object' && value.name && value.style)
  .map(([key, value]) => [toKebabCase(key), value])
  .sort(([left], [right]) => left.localeCompare(right));
const themes = Object.freeze(Object.fromEntries(themeEntries));
const themeIDs = Object.freeze(Object.keys(themes));
const supportedLanguageList = Object.freeze(
  Object.keys(languageAliases)
    .filter((language) => isSupportedLanguage(language))
    .sort(),
);

let currentThemeID = themes['github-light'] ? 'github-light' : themeIDs[0];

function toKebabCase(value) {
  return value
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/_/g, '-')
    .toLowerCase();
}

function normalizeLanguage(value) {
  if (typeof value !== 'string') return 'plain';
  let candidate = value.trim().toLowerCase().replace(/^language-/, '');
  if (!candidate) return 'plain';
  if (isSupportedLanguage(candidate)) return candidate;

  const aliases = {
    'c#': 'csharp',
    'c++': 'cpp',
    'obj-c': 'objective-c',
    objc: 'objective-c',
    shellscript: 'shell',
    'shell-session': 'shell',
    'source-shell': 'shell',
    'source-code': 'plain',
    'no-highlight': 'plain',
    nohighlight: 'plain',
    js: 'javascript',
    ts: 'typescript',
    text: 'plain',
  };
  const aliased = aliases[candidate];
  return aliased && isSupportedLanguage(aliased) ? aliased : 'plain';
}

function resolveTheme(themeReference) {
  if (themeReference && typeof themeReference === 'object') {
    if (!themeReference.name || !themeReference.style) {
      throw new TypeError('theme object must include name and style');
    }
    return themeReference;
  }
  if (typeof themeReference === 'string' && themes[themeReference]) {
    return themes[themeReference];
  }
  if (themes[currentThemeID]) return themes[currentThemeID];
  throw new Error('Lexlight has no active theme');
}

function tokenize(code, language, themeReference) {
  const normalizedLanguage = normalizeLanguage(language);
  const result = codeToTokens(String(code ?? ''), {
    lang: normalizedLanguage,
    theme: resolveTheme(themeReference),
  });
  return JSON.stringify({
    tokens: result.tokens.map((line) =>
      line.map((token) => ({
        content: token.content,
        offset: token.offset,
        color: token.color,
        bgColor: token.bgColor,
        fontStyle: token.fontStyle,
      })),
    ),
    fg: result.fg,
    bg: result.bg,
    language: normalizedLanguage,
    themeName: result.themeName,
  });
}

function languageForElement(element) {
  const explicit =
    element.dataset?.language ||
    element.getAttribute('data-lang') ||
    Array.from(element.classList)
      .find((name) => name.startsWith('language-'))
      ?.slice('language-'.length);
  return normalizeLanguage(explicit);
}

function tokenStyle(token) {
  const declarations = [];
  if (token.color) declarations.push(`color:${token.color}`);
  if (token.bgColor) declarations.push(`background-color:${token.bgColor}`);
  const fontStyle = token.fontStyle || 0;
  if (fontStyle & 1) declarations.push('font-style:italic');
  if (fontStyle & 2) declarations.push('font-weight:700');
  const decorations = [];
  if (fontStyle & 4) decorations.push('underline');
  if (fontStyle & 8) decorations.push('line-through');
  if (decorations.length) declarations.push(`text-decoration-line:${decorations.join(' ')}`);
  return declarations.join(';');
}

function renderTokens(element, source, result) {
  const lineEndings = source.match(/\r\n|\r|\n/g) || [];
  const fragment = element.ownerDocument.createDocumentFragment();
  result.tokens.forEach((line, index) => {
    for (const token of line) {
      if (!token.content) continue;
      const style = tokenStyle(token);
      if (style) {
        const span = element.ownerDocument.createElement('span');
        span.setAttribute('style', style);
        span.textContent = token.content;
        fragment.appendChild(span);
      } else {
        fragment.appendChild(element.ownerDocument.createTextNode(token.content));
      }
    }
    if (lineEndings[index]) {
      fragment.appendChild(element.ownerDocument.createTextNode(lineEndings[index]));
    }
  });
  element.replaceChildren(fragment);
  element.classList.add('hljs', 'highlights');
  element.classList.toggle('hljs-plaintext', result.language === 'plain');
  element.dataset.highlighted = 'yes';
  if (result.fg) element.style.color = result.fg;
  if (result.bg) element.style.backgroundColor = result.bg;
}

function highlightElement(element, options = {}) {
  const source = element.textContent || '';
  const language = normalizeLanguage(languageForElement(element));
  const result = codeToTokens(source, {
    lang: language,
    theme: resolveTheme(options.theme ?? options.themeID),
  });
  renderTokens(element, source, { ...result, language });
  return element;
}

function highlightAll(root = document, options = {}) {
  const blocks = root.querySelectorAll('pre code');
  let count = 0;
  blocks.forEach((element) => {
    if (
      element.closest('[data-no-highlight]') ||
      ['mermaid', 'plantuml', 'markmap'].some((language) =>
        element.classList.contains(`language-${language}`),
      )
    ) {
      return;
    }
    try {
      highlightElement(element, options);
      count += 1;
    } catch (error) {
      console.error('Lexlight highlight error:', error);
    }
  });
  return count;
}

function setTheme(themeID) {
  if (!themes[themeID]) throw new Error(`Unknown Lexlight theme: ${themeID}`);
  currentThemeID = themeID;
  return currentThemeID;
}

function supportedLanguages() {
  return [...supportedLanguageList];
}

globalThis.Lexlight = Object.freeze({
  version,
  themeIDs,
  supportedLanguages,
  normalizeLanguage,
  tokenize,
  highlightElement,
  highlightAll,
  setTheme,
});
