import { MessageInfoModel } from '../types/message'
import { StoreClass } from '../utils/StoreClass'
import { emitter } from '@kit.BasicServicesKit'
import { router } from '@kit.ArkUI'
import { formatTime } from '../utils/Util'
import { PopupItem } from '../types/popup'
import { scanBarcode, scanCore } from '@kit.ScanKit'

@Preview
@Component
export default struct WeChat {
  @State
  list: MessageInfoModel[] = []
  @State
  showDropDown: boolean = false
  @State
  popList: PopupItem[] = [
    {
      title: '发起群聊',
      icon: $r('app.media.ic_public_message'),
      itemClick: () => {
        AlertDialog.show({
          message: "1"
        })
      }
    },
    {
      title: '添加朋友',
      icon: $r('app.media.ic_public_add_friend'),
      itemClick: () => {
        AlertDialog.show({
          message: "2"
        })
      }
    },
    {
      title: '扫一扫',
      icon: $r('app.media.ic_public_scan'),
      itemClick: async () => {

        if (canIUse('SystemCapability.Multimedia.Scan.Core')) {
          // 1. 定义扫码参数
          let options: scanBarcode.ScanOptions = {
            scanTypes: [scanCore.ScanType.ALL],
            enableMultiMode: true,
            enableAlbum: true
          };

          if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
            // 2. 启动扫码, 拉起扫码的界面
            try {
              const result = await scanBarcode.startScanForResult(getContext(), options)
              AlertDialog.show({
                message: JSON.stringify(result)
              })
            } catch (e) {
              console.log(e)
            }
          }
        }
      }
    },
    {
      title: '收付款',
      icon: $r('app.media.ic_public_receive'),
      itemClick: () => {
        router.pushUrl({
          url: "pages/WeChat/PayQrCode/PayQrCode"
        })
      }
    }
  ]

  aboutToAppear(): void {
    this.list = StoreClass.getAllChatLastMessage()

    // 订阅
    emitter.on(StoreClass.wechat_key, () => {
      this.list = StoreClass.getAllChatLastMessage()
    })
  }

  transTime(time: number) {
    // 把时间戳转化utc时间
    const dateObj = new Date(time)
    // 获取年
    const year = dateObj.getFullYear()
    // 获取月
    const month = dateObj.getMonth() // 0 - 11
    // 获取日
    const date = dateObj.getDate()
    // 获取时
    const hours = dateObj.getHours()
    // 获取分
    const minutes = dateObj.getMinutes()
    // 是不是今年发送的
    if (year === new Date().getFullYear()) {
      // 是不是这个月发送的
      if (month === new Date().getMonth()) {
        // 是不是今天发送的
        if (date === new Date().getDate()) {
          return hours.toString().padStart(2, "0") + ":" + minutes.toString().padStart(2, "0")
        } else {
          return `${new Date().getDate() - date}天前`
        }
      } else {
        return `${month}月${date}日` + ""
      }
    } else {
      return `${year}年${month}月${date}日` + ""
    }

  }

  // 自定义列表滑动删除按钮
  @Builder
  getListEnd(user_id: string) {
    Row() {
      Text("删除")
        .fontColor($r("app.color.white"))
        .width(100)
        .textAlign(TextAlign.Center)
    }
    .height(70)
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r("app.color.danger"))
    .onClick(() => {
      // 删除首选项的数据
      StoreClass.removeChatAllMessage(user_id)

      // 删除UI界面的数据
      const index = this.list.findIndex((item: MessageInfoModel) => item.connectUser.user_id === user_id)


      this.list.splice(index, 1)
      // AlertDialog.show({
      //   message: index + ""
      // })
    })

  }

  @Builder
  getDropDown() {
    Column() {
      ForEach(this.popList, (item: PopupItem) => {
        Row({ space: 5 }) {
          Image(item.icon)
            .width(20)
            .height(20)
            .fillColor("#ffffff")

          Text(item.title)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontColor("#ffffff")
            .onClick(() => {
              item.itemClick && item.itemClick()
            })
        }
        .width("100%")
        .padding({
          left: 10,
          right: 10
        })
        .height(48)
        .justifyContent(FlexAlign.Center)

      })
    }
    .width(120)
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.End }) {
          Text("微信")
            .fontColor("#2A2929")
            .width("100%")
            .textAlign(TextAlign.Center)

          Image($r("app.media.ic_public_add_norm"))
            .width(20)
            .height(20)
            .fillColor("#2A2929")
            .margin({
              right: 20

            })
            .onClick(() => {
              this.showDropDown = true
            })
            .bindPopup($$this.showDropDown, {
              builder: this.getDropDown,
              onStateChange: (event) => {
                this.showDropDown = event.isVisible
              },
              backgroundBlurStyle: BlurStyle.NONE,
              popupColor: "#4d4d4d"
            })
        }
        .width("100%")
      }
      .width("100%")
      .justifyContent(FlexAlign.Center)
      .height(50)

      List() {
        ForEach(this.list, (item: MessageInfoModel) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.connectUser.avatar)
                .width(50)
                .height(50)
                .borderRadius(5)

              Column({ space: 10 }) {
                Row() {
                  Text(item.connectUser.username)
                    .fontSize(16)
                    .fontColor($r("app.color.text_primary"))
                    .margin({ top: 10 })
                  Text(formatTime(item.sendTime))
                    .fontSize(12)
                    .fontColor($r("app.color.text_primary"))
                    .margin({ top: 10 })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")

                Text(item.messageContent)
                  .maxLines(1)
                  .fontSize(14)
                  .fontColor($r("app.color.text_second"))
              }
              .layoutWeight(1)
              .height(50)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                top: 3,
                bottom: 3
              })
            }
            .onClick(() => {
              router.pushUrl({
                url: "pages/WeChat/ChatDetail/ChatDetail",
                params: item.connectUser
              })
            })
            .stateStyles({
              normal: {
                .backgroundColor($r("app.color.white"))
              },
              pressed: {
                .backgroundColor($r("app.color.back_color"))
              }
            })
          }
          .padding({
            top: 10,
            bottom: 10
          })

          .swipeAction({
            end: {
              builder: () => {
                this.getListEnd(item.connectUser.user_id)
              }
            }
          })
        })

      }
      .width("100%")
      .height("100%")
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: $r("app.color.border_color")
      })
      .padding({
        left: 10,
        right: 10
      })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#fff")
  }
}
