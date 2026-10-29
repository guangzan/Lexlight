(() => {
  if (typeof globalThis.TransformStream === 'undefined') {
    globalThis.TransformStream = class TransformStream {};
  }
  if (typeof globalThis.atob !== 'function') {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    globalThis.atob = (input) => {
      const raw = String(input).replace(/[^A-Za-z0-9+/=]/g, '');
      let output = '';
      for (let i = 0; i < raw.length; i += 4) {
        const a = alphabet.indexOf(raw[i]);
        const b = alphabet.indexOf(raw[i + 1] || '=');
        const c = alphabet.indexOf(raw[i + 2] || '=');
        const d = alphabet.indexOf(raw[i + 3] || '=');
        const value = (a << 18) | (b << 12) | ((c & 63) << 6) | (d & 63);
        output += String.fromCharCode((value >> 16) & 255);
        if (raw[i + 2] !== '=' && raw[i + 2] !== undefined) {
          output += String.fromCharCode((value >> 8) & 255);
        }
        if (raw[i + 3] !== '=' && raw[i + 3] !== undefined) {
          output += String.fromCharCode(value & 255);
        }
      }
      return output;
    };
  }
  if (typeof globalThis.TextEncoder === 'undefined') {
    globalThis.TextEncoder = class TextEncoder {
      encode(input = '') {
        const output = [];
        for (let i = 0; i < input.length; i += 1) {
          let codePoint = input.charCodeAt(i);
          if (codePoint >= 0xd800 && codePoint <= 0xdbff && i + 1 < input.length) {
            const low = input.charCodeAt(i + 1);
            if (low >= 0xdc00 && low <= 0xdfff) {
              codePoint = 0x10000 + ((codePoint - 0xd800) << 10) + (low - 0xdc00);
              i += 1;
            }
          }
          if (codePoint <= 0x7f) output.push(codePoint);
          else if (codePoint <= 0x7ff) {
            output.push(0xc0 | (codePoint >> 6), 0x80 | (codePoint & 63));
          } else if (codePoint <= 0xffff) {
            output.push(
              0xe0 | (codePoint >> 12),
              0x80 | ((codePoint >> 6) & 63),
              0x80 | (codePoint & 63),
            );
          } else {
            output.push(
              0xf0 | (codePoint >> 18),
              0x80 | ((codePoint >> 12) & 63),
              0x80 | ((codePoint >> 6) & 63),
              0x80 | (codePoint & 63),
            );
          }
        }
        return Uint8Array.from(output);
      }

      encodeInto(input, destination) {
        const bytes = this.encode(input);
        const written = Math.min(bytes.length, destination.length);
        destination.set(bytes.subarray(0, written));
        let read = 0;
        let count = 0;
        while (read < input.length && count < written) {
          const codePoint = input.codePointAt(read);
          const length =
            codePoint <= 0x7f ? 1 : codePoint <= 0x7ff ? 2 : codePoint <= 0xffff ? 3 : 4;
          if (count + length > written) break;
          count += length;
          read += codePoint > 0xffff ? 2 : 1;
        }
        return { read, written: count };
      }
    };
  }
  if (typeof globalThis.TextDecoder === 'undefined') {
    globalThis.TextDecoder = class TextDecoder {
      constructor(_label = 'utf-8', options = {}) {
        this.ignoreBOM = Boolean(options.ignoreBOM);
      }

      decode(input = new Uint8Array()) {
        const bytes = input instanceof Uint8Array ? input : new Uint8Array(input);
        let index = 0;
        let output = '';
        if (!this.ignoreBOM && bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) {
          index = 3;
        }
        while (index < bytes.length) {
          const first = bytes[index++];
          if (first < 0x80) {
            output += String.fromCharCode(first);
            continue;
          }

          let codePoint;
          let remaining;
          if ((first & 0xe0) === 0xc0) {
            codePoint = first & 31;
            remaining = 1;
          } else if ((first & 0xf0) === 0xe0) {
            codePoint = first & 15;
            remaining = 2;
          } else if ((first & 0xf8) === 0xf0) {
            codePoint = first & 7;
            remaining = 3;
          } else {
            output += '\ufffd';
            continue;
          }

          if (index + remaining > bytes.length) {
            output += '\ufffd';
            break;
          }
          let valid = true;
          for (let offset = 0; offset < remaining; offset += 1) {
            const next = bytes[index++];
            if ((next & 0xc0) !== 0x80) {
              valid = false;
              break;
            }
            codePoint = (codePoint << 6) | (next & 63);
          }
          if (!valid) {
            output += '\ufffd';
          } else if (codePoint <= 0xffff) {
            output += String.fromCharCode(codePoint);
          } else {
            codePoint -= 0x10000;
            output += String.fromCharCode(0xd800 + (codePoint >> 10), 0xdc00 + (codePoint & 1023));
          }
        }
        return output;
      }
    };
  }
})();
