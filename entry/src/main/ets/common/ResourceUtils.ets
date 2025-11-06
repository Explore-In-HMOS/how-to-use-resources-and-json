import { UIContext } from '@kit.ArkUI';

export class ResourceUtils {
  static getHostCtx(ui: UIContext) {
    const host = ui.getHostContext();
    if (!host) {
      throw new Error('[ResourceUtils] Host context is undefined');
    }
    return host;
  }

  static getStringSync(ui: UIContext, res: Resource): string {
    const host = ResourceUtils.getHostCtx(ui);
    return host.resourceManager.getStringSync(res.id);
  }

  static async getString(ui: UIContext, res: Resource): Promise<string> {
    const host = ResourceUtils.getHostCtx(ui);
    return host.resourceManager.getString(res.id);
  }

  static async readRawfileText(ui: UIContext, filename: string): Promise<string> {
    const host = ResourceUtils.getHostCtx(ui);
    const bytes = await host.resourceManager.getRawFileContent(filename);
    return ResourceUtils.utf8Decode(bytes); // <<< UTF-8 decoder
  }

  static async readRawfileJson<T>(ui: UIContext, filename: string): Promise<T> {
    const text = await ResourceUtils.readRawfileText(ui, filename);
    return JSON.parse(text) as T;
  }

  private static utf8Decode(bytes: Uint8Array): string {
    let out = '';
    let i = 0;
    const len = bytes.length;

    if (len >= 3 && bytes[0] === 0xEF && bytes[1] === 0xBB && bytes[2] === 0xBF) {
      i = 3;
    }

    while (i < len) {
      const b1 = bytes[i++];

      // 1 byte (ASCII)
      if (b1 < 0x80) {
        out += String.fromCharCode(b1);
        continue;
      }

      // 2 byte
      if ((b1 & 0xE0) === 0xC0) {
        if (i >= len) { out += '\uFFFD'; break; }
        const b2 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80) { out += '\uFFFD'; continue; }
        const cp = ((b1 & 0x1F) << 6) | (b2 & 0x3F);
        out += String.fromCharCode(cp);
        continue;
      }

      // 3 byte
      if ((b1 & 0xF0) === 0xE0) {
        if (i + 1 >= len) { out += '\uFFFD'; break; }
        const b2 = bytes[i++], b3 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80 || (b3 & 0xC0) !== 0x80) { out += '\uFFFD'; continue; }
        const cp = ((b1 & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F);
        out += String.fromCharCode(cp);
        continue;
      }

      // 4 byte
      if ((b1 & 0xF8) === 0xF0) {
        if (i + 2 >= len) { out += '\uFFFD'; break; }
        const b2 = bytes[i++], b3 = bytes[i++], b4 = bytes[i++];
        if ((b2 & 0xC0) !== 0x80 || (b3 & 0xC0) !== 0x80 || (b4 & 0xC0) !== 0x80) {
          out += '\uFFFD'; continue;
        }
        const cp = ((b1 & 0x07) << 18) | ((b2 & 0x3F) << 12) | ((b3 & 0x3F) << 6) | (b4 & 0x3F);
        const offset = cp - 0x10000;
        const high = 0xD800 + (offset >> 10);
        const low  = 0xDC00 + (offset & 0x3FF);
        out += String.fromCharCode(high, low);
        continue;
      }

      out += '\uFFFD';
    }

    return out;
  }
}
