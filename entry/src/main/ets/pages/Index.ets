import { UIContext } from '@kit.ArkUI';
import { City } from '../model/City';
import { ResourceUtils } from '../common/ResourceUtils';

interface Payload {
  cities: City[];
}

@Entry
@Component
struct Index {
  @State statusMsg: string = '';
  @State cities: City[] = [];
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  readonly titleRes: Resource = $r('app.string.title_cities');

  private ui(): UIContext {
    const u = this.getUIContext();
    if (!u) {
      throw new Error('[Index] UIContext not available');
    }
    return u;
  }

  private getStatusColor(): Resource {
    if (this.hasError) {
      return $r('app.color.status_error');
    }
    if (this.isLoading) {
      return $r('app.color.status_info');
    }
    return $r('app.color.status_success');
  }

  async aboutToAppear() {
    const ui = this.ui();
    this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_loading'));

    try {
      const data = await ResourceUtils.readRawfileJson<Payload>(ui, 'cities.json');
      this.cities = data?.cities ?? [];
      this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_loaded'));
      this.hasError = false;
    } catch (e) {
      console.error(`[Index] JSON load error: ${(e as Error)?.message}`);
      this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_error'));
      this.hasError = true;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      Text(this.titleRes)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')

      Text(this.statusMsg)
        .fontSize(14)
        .fontColor(this.getStatusColor())
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ bottom: 6 })

      if (this.cities.length > 0) {
        List() {
          ForEach(this.cities, (item: City) => {
            ListItem() {
              Row({ space: 8 }) {
                Column() {
                  Text(`${item.name} — ${item.country}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)

                  // İkincil metin rengi: color.json’dan
                  Text(`Population: ${item.pop.toLocaleString()}`)
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                }
              }
              .padding(12)
            }
          }, (item: City) => item.name)
        }
        .width('100%')
        .height('60%')
        .edgeEffect(EdgeEffect.Spring)
      } else if (!this.isLoading && !this.hasError) {
        Text('No data found.')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .width('100%')
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
