import Connent from './component/Connect'
import Discover from './component/Discover'

import Home from './component/Home'
import My from './component/My'
import { TabBarClass } from './types/TabBarClass'


@Entry
@Component
struct OnLineIndexPage {
  @State
  tabBarList: TabBarClass[] = [
    {
      id: 1,
      icon: $r('app.media.ic_public_contacts'),
      name: 'wechat',
      title: '微信',
      selectIcon: $r('app.media.ic_public_contacts_filled')
    },
    {
      id: 2,
      icon: $r('app.media.ic_public_contacts'),
      name: 'connect',
      title: '联系人',
      selectIcon: $r('app.media.ic_public_contacts_filled')
    },
    {
      id: 3,
      icon: $r('app.media.ic_public_contacts'),
      name: 'discover',
      title: '发现',
      selectIcon: $r('app.media.ic_public_contacts_filled')
    },

    {
      id: 4,
      icon: $r('app.media.ic_public_contacts'),
      name: 'my',
      title: '我的',
      selectIcon: $r('app.media.ic_public_contacts_filled')
    }
  ]
  @State
  activeIndex: number = 0

  @Builder
  TabBarItem(item: TabBarClass) {
    Column() {
      Image(this.tabBarList[this.activeIndex].name === item.name ? item.selectIcon : item.icon)
        .width(20)
        .aspectRatio(1)

      Text(item.title)
        .fontSize(12)
        .fontColor(this.tabBarList[this.activeIndex].name === item.name ? Color.Green : Color.Black)
        .margin({
          top: 5
        })

    }
  }

  build() {
    Column() {
      Tabs({ index: $$this.activeIndex }) {
        ForEach(this.tabBarList, (item: TabBarClass) => {
          TabContent() {
            if (item.name === "wechat") {
              Home()
            } else if (item.name === "connect") {
              Connent()
            } else if (item.name === "discover") {
              Discover()
            } else if (item.name === "my") {
              My()
            }
          }.tabBar(this.TabBarItem(item))
        }, (item: TabBarClass) => item.id.toString())
      }.barPosition(BarPosition.End)
    }
    .height('100%')
    .width('100%')
    .backgroundColor("#fff")
  }
}