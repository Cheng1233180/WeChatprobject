import { DefaultUserList, UserInfo } from '../types/users'
import router from '@ohos.router'


@Component
struct Connect {

  @State
  List:UserInfo[]=[]
  @State
  @Watch("getName")
  searchName:string=""

  aboutToAppear(): void {
    this.List=DefaultUserList
  }

  getName(){
      this.List=DefaultUserList.filter((user:UserInfo)=>{
        return user.username.includes(this.searchName)
      })
  }


  build() {
    Column() {
      // 搜索栏
      Row() {
        Search({ placeholder: "搜索" ,value: $$this.searchName})
          .backgroundColor($r("app.color.white"))
          .height(30)
          .borderRadius(4)
      }
      .width("100%")
      .padding({
        left: 10,
        right: 10
      })


      // 联系人列表
      List() {
        ForEach(this.List, (item:UserInfo) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.avatar)
                .width(30)
                .height(30)
                .borderRadius(4)

              Column() {
                Text(item.username)
                  .fontSize(14)
                  .fontColor($r("app.color.text_primary"))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
            }
            .padding({
              left: 10,
              right: 10
            })
            .height(60)
            .width("100%")
            .stateStyles({
              pressed: {
                .backgroundColor($r("app.color.back_color"))
              },
              normal: {
                .backgroundColor($r("app.color.white"))
              }
            })
          }
          .onClick(() => {
            router.pushUrl({
              url: "pages/WeChat/ChatDetail/ChatDetail",
              params: item
            })
          })
        }, (item: UserInfo) => item.user_id)
      }

      .width("100%")
      .height("100%")
      .padding({
        top: 10,
        bottom: 10
      })
      .divider({
        strokeWidth: 1,
        color: $r("app.color.border_color")
      })
      .layoutWeight(1)
      .backgroundColor($r("app.color.white"))
    }
    .width("100%")
    .height("100%")
    .padding({
      top: 20
    })
    .backgroundColor($r("app.color.back_color"))
  }
}

export default Connect