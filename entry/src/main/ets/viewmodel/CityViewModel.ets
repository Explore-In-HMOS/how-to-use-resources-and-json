import { UIContext } from '@kit.ArkUI';
import { City } from '../model/City';
import { ResourceUtils } from '../common/ResourceUtils';

interface Payload {
  cities: City[];
}

@Observed
export class CityViewModel {
  cities: City[] = [];
  isLoading: boolean = true;
  hasError: boolean = false;
  statusMsg: string = '';

  getStatusColor(): Resource {
    if (this.hasError) {
      return $r('app.color.status_error');
    }
    if (this.isLoading) {
      return $r('app.color.status_info');
    }
    return $r('app.color.status_success');
  }

  // Veri çekme işini buraya taşıyoruz
  async loadData(ui: UIContext) {
    this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_loading'));
    this.isLoading = true;

    try {
      const data = await ResourceUtils.readRawfileJson<Payload>(ui, 'cities.json');
      this.cities = data?.cities ?? [];
      this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_loaded'));
      this.hasError = false;
    } catch (e) {
      console.error(`[CityViewModel] JSON load error: ${(e as Error)?.message}`);
      this.statusMsg = await ResourceUtils.getString(ui, $r('app.string.hint_error'));
      this.hasError = true;
    } finally {
      this.isLoading = false;
    }
  }
}