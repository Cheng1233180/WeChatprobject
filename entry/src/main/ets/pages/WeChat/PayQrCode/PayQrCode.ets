import { generateBarcode, scanCore } from "@kit.ScanKit"
import { router } from "@kit.ArkUI"

@Entry
@Component
export default struct PayQrCode {

  @State
  payParams:string=Math.random().toString()

  @State
  barCodeImage:PixelMap|null=null

  async createBarCode(){
    try {
      if (canIUse('SystemCapability.Multimedia.Scan.Core')) {
        if (canIUse('SystemCapability.Multimedia.Scan.GenerateBarcode')) {
          this.barCodeImage=await generateBarcode.createBarcode(this.payParams,{
            scanType:scanCore.ScanType.CODE128_CODE,
            height:200,
            width:800
          })
        }
      }
    } catch (e) {
      console.log(e)
    }
  }
  aboutToAppear(): void {
    this.refreshQrCode()
    this.createBarCode()
  }
  refreshQrCode(){
    setInterval(()=>{
      this.payParams=Math.random().toString()
    },3000)
  }


  build() {
    Column() {
      Row(){
        Stack({alignContent:Alignment.Start})
        {
          Image($r("app.media.ic_public_arrow_left"))
            .width(30)
            .height(30)
            .fillColor("#ffffff")
            .zIndex(2)
            .onClick(()=>{
              router.back()
            })

          Text("收付款")
            .fontColor("#ffffff")
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .width("100%")
        }
      }
      .width("100%")
      .height(50)

      Column(){
        Column() {
          Row({space:10}) {
            Image($r("app.media.ic_public_scan"))
              .width(20)
              .height(20)
              .fillColor("#57ab70")

            Text("付款码")
              .fontColor("#57ab70")
              .fontSize(16)

          }
          .width("100%")
          .height(60)
          .padding({
            left:10,
            right:10
          })
          .border({
            width:{bottom:1},
            color:"#f4f5f6"

          })

          Column(){
            Text("优先使用XXX银行储蓄卡付款")
              .fontColor("#818181")
              .fontSize(12)
              .margin({
                bottom:10
              })

            QRCode(this.payParams)
              .width(140)
              .height(140)
              .margin({
                top:10,
                bottom:20
              })
            Image(this.barCodeImage)
              .width(280)
              .height(100)


          }
          .margin({
            top:10,
            bottom:10
          })

        }
        .width("100%")
        .backgroundColor("#ffffff")
        .borderRadius(4)

      }
      .layoutWeight(1)
      .width("100%")
      .padding(10)


    }
    .width('100%')
    .height('100%')
    .backgroundColor("#57ab70")
  }
}