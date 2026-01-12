import { UIContext } from '@kit.ArkUI';
import { City } from '../model/City';
import { CityViewModel } from '../viewmodel/CityViewModel';

@Entry
@Component
struct Index {
  @State vm: CityViewModel = new CityViewModel();

  readonly titleRes: Resource = $r('app.string.title_cities');

  private ui(): UIContext {
    const u = this.getUIContext();
    if (!u) {
      throw new Error('[Index] UIContext not available');
    }
    return u;
  }

  async aboutToAppear() {
    await this.vm.loadData(this.ui());
  }

  build() {
    Column({ space: 12 }) {
      Text(this.titleRes)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')

      Text(this.vm.statusMsg)
        .fontSize(14)
        .fontColor(this.vm.getStatusColor())
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ bottom: 6 })

      if (this.vm.cities.length > 0) {
        List() {
          ForEach(this.vm.cities, (item: City) => {
            ListItem() {
              Row({ space: 8 }) {
                Column() {
                  Text(`${item.name} — ${item.country}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)

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
      } else if (!this.vm.isLoading && !this.vm.hasError) {
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