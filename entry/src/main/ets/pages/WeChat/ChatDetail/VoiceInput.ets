import { VoiceRecordEnum } from '../types/VoiceRecordEnum'

@Component
export default struct VoiceInput {

  @Consume
  voiceState:VoiceRecordEnum



  @Builder
  getDisplayContent(){
    if (this.voiceState===VoiceRecordEnum.Cancel){
      Row(){

      }
      .width(100)
      .height(80)
      .backgroundColor("#e75f58")
      .borderRadius(20)
      .margin({
        left:20
      })
    }
    if (this.voiceState===VoiceRecordEnum.RecordIng)
    {
      Row(){

      }
      .width(180)
      .height(80)
      .backgroundColor("#8aec71")
      .borderRadius(20)
    }

    if (this.voiceState===VoiceRecordEnum.Transfer){
      Row(){}
      .width(200)
      .height(180)
      .backgroundColor("#8aec71")
      .borderRadius(20)
    }


  }




  build() {
    Stack({alignContent:Alignment.Bottom}){
      Column(){
        Column(){
          this.getDisplayContent()
        }
        .width("100%")
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(this.voiceState===VoiceRecordEnum.Cancel?HorizontalAlign.Start:HorizontalAlign.Center)

        Row(){
          Row(){
            Image($r("app.media.ic_public_cancel"))
              .width(30)
              .height(30)
              .fillColor("#919191")

          }
          .width(70)
          .aspectRatio(1)
          .borderRadius(35)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.voiceState===VoiceRecordEnum.Cancel?Color.Green:"#323232")
          .rotate({
            angle:-10
          })
          Row(){
            Text("文")
              .fontSize(24)
              .textAlign(TextAlign.Center)
              .fontColor("#919191")
          }
          .width(70)
          .aspectRatio(1)
          .borderRadius(35)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.voiceState===VoiceRecordEnum.Transfer?Color.Blue:"#323232")
          .rotate({
            angle:10
          })


        }
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left:40,
          right:40
        })
        .margin({
          bottom:30
        })

        Stack(){
          Image($r("app.media.ic_public_output"))
            .width("100%")
            .height(120)
            .fillColor(this.voiceState===VoiceRecordEnum.RecordIng?"#a4a4a4":"#323232")
            .scale({
              x:1.2
            })
          Image($r("app.media.ic_public_recorder"))
            .width(30)
            .aspectRatio(1)
            .fillColor(this.voiceState===VoiceRecordEnum.RecordIng?"#515151":"#a4a4a4")

        }
        .width("100%")

      }




    }
    .width('100%')
    .height('100%')
    .backgroundColor("#CC3E3E3E")
  }
}

