

import WeChat from '../views/WeChat'

@Entry
@Component
export default struct Home {
  build() {
    Column() {
      WeChat()
    }
    .width('100%')
    .height('100%')
  }
}