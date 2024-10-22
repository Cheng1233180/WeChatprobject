import { display, promptAction } from '@kit.ArkUI'
import { PopupItem } from '../types/popup'
import { VoiceRecordEnum } from '../types/VoiceRecordEnum'
import VoiceInput from './VoiceInput'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { camera, cameraPicker as picker } from '@kit.CameraKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'
import AudioCapture from '../utils/AudioCapturer'
import File from '@system.file'
import { FileOperate } from '../utils/FileOperate'
import { UserInfo } from '../types/users'

@Component
struct BottomInput {

  @State
  talker:UserInfo={} as UserInfo

  @State
  showVoice: boolean = false

  @State
  content: string = ""
  // 控制按钮说话按钮的弹层
  @State
  showVoiceCom: boolean = false
  // 记录屏幕整体的宽度
  @State
  screenWidth: number = 0
  // 记录屏幕整体的高度
  screenHeight: number = 0
  // 保存当前的状态
  @Provide
  voiceState: VoiceRecordEnum = VoiceRecordEnum.RecordIng
  // 定义底部菜单的数据
  @State
  bottomList: PopupItem[] = [
    {
      icon: $r('app.media.ic_public_photo'),
      title: '照片',
      itemClick: () => {
       this.sendPhoto()
      }
    },
    {
      icon: $r('app.media.ic_public_carema'),
      title: '拍摄',
      itemClick: () => {
        // 唤醒相机
       this.openCamera()
      }
    },
    {
      icon: $r('app.media.ic_statusbar_gps'),
      title: '位置',

    },
    {
      icon: $r('app.media.ic_public_voice'),
      title: '语音输入',

    },
    {
      icon: $r("app.media.ic_public_collect"),
      title: '收藏',

    },
    {
      icon: $r("app.media.ic_public_contacts_filled"),
      title: '个人名片',

    },
    {
      icon: $r("app.media.ic_public_folder_filled"),
      title: '文件',

    },
    {
      icon: $r("app.media.ic_public_music_filled"),
      title: '音乐',
    }
  ]
  // 定义一个变量, 用来控制底部菜单的显示与隐藏
  @State
  showBottomCard: boolean = false

  @State
  duration:number=0

  @State
  timer:number=-1

  @State
  audioFilePath:string=""


  @Builder
    getBottomCard(item:PopupItem){
    Column(){
      Column(){
        Image(item.icon)
          .width(30)
          .height(30)
          .fillColor("#4c4c4c")
      }
      .backgroundColor("#ffffff")
      .width(56)
      .aspectRatio(1)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(item.title)
        .fontSize(12)
        .margin({
          top:10
        })
        .fontColor("#818181")

    }
    .layoutWeight(1)
    }

  async aboutToAppear(): Promise<void> {
    this.screenWidth=px2vp(display.getDefaultDisplaySync().width);
    this.screenHeight=px2vp(display.getDefaultDisplaySync().height);

    await AudioCapture.init()

    }
    sendTextMessage:(Content:string)=>void=()=>{

    }
    sendImageMessage:(filePath:string)=>void=()=>{

    }
    sendVideoMessage:(filePath:string)=>void=()=>{

    }
    sendAudioMessage:(filePath:string,duration:number)=>void=()=>{

    }


    async sendPhoto(){

    const photoViewPicker =new photoAccessHelper.PhotoViewPicker()
      const result=await photoViewPicker.select({
        MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
        maxSelectNumber:5
      })

      if (result.photoUris.length) {
        result.photoUris.forEach((item)=>{
          const file=fileIo.openSync(item,fileIo.OpenMode.READ_ONLY)
          const newFileName=getContext().filesDir+"/"+Date.now()+"jpg"
          fileIo.copyFileSync(file.fd,newFileName)
          fileIo.closeSync(file.fd)
          this.sendImageMessage(newFileName)

        })
      }


    }

    async openCamera(){

      try {
        let pickerProfile: picker.PickerProfile = {
          cameraPosition:camera.CameraPosition.CAMERA_POSITION_BACK
        };
        let pickerResult:picker.PickerResult=await picker.pick(getContext(), [
          picker.PickerMediaType.PHOTO,picker.PickerMediaType.VIDEO
        ],pickerProfile)
        if (pickerResult.mediaType === "photo" && pickerResult.resultUri !== "") {
          const file=fileIo.openSync(pickerResult.resultUri,fileIo.OpenMode.READ_ONLY)
          const newFileName=getContext().filesDir+"/"+Date.now()+"jpg"
          fileIo.copyFileSync(file.fd,newFileName)
          fileIo.closeSync(file.fd)
          this.sendImageMessage(newFileName)
        }else {

          const file=fileIo.openSync(pickerResult.resultUri,fileIo.OpenMode.READ_ONLY)

          const newFileName=getContext().filesDir+"/"+Date.now()+".mp4"

          fileIo.copyFileSync(file.fd,newFileName)

          fileIo.closeSync(file.fd)

          this.sendVideoMessage(newFileName)

        }

      } catch (error) {
        let err=error as BusinessError;
        console.error(`the pick call failed. error code: ${err.code}`)
      }

    }


    checkMicroPhonePermission(){

    const  manager=abilityAccessCtrl.createAtManager()

      const bundleInfo=bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)

      const status=manager.checkAccessTokenSync(bundleInfo.appInfo.accessTokenId,"ohos.permission.MICROPHONE")

      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        (getContext() as common.UIAbilityContext).startAbility({
          bundleName: "com.huawei.hmos.settings",
          abilityName: "com.huawei.hmos.settings.MainAbility",
          uri: "application_info_entry",
          parameters:{
            pushParams:bundleInfo.name
          }
        })
      }else {
        this.showVoiceCom=true

        this.collectVoice()
      }

    }

    collectVoice(){

    this.audioFilePath= FileOperate.createAudioFile(this.talker.user_id)

      AudioCapture.start(this.audioFilePath)

    this.startTime()
    }

    startTime(){
    this.timer=setInterval(()=>{
      this.duration++

      promptAction.showToast({
        message:`当前语音:${this.duration}秒`
      })

    },1000)
    }

    endTime(){
    clearInterval(this.timer)
    }
    releaseFinger(){
    this.showVoiceCom=false

      AudioCapture.stop()

      this.endTime()

      if (this.voiceState === VoiceRecordEnum.RecordIng) {
        if (this.duration < 1) {
          return promptAction.showToast({
            message:"内容是间不足一秒！"
          })
        }
        this.sendAudioMessage(this.audioFilePath,this.duration)
        this.audioFilePath=""
        this.duration=0
      }else if (this.voiceState===VoiceRecordEnum.Cancel){

        this.duration=0
        this.audioFilePath=""
      }else if (this.voiceState===VoiceRecordEnum.Transfer){
        this.duration=0
        this.audioFilePath=""
      }

    }

    aboutToDisappear(): void {
    AudioCapture.release()
    }


    @Builder
    getVoiceCom(){
    Column(){
      VoiceInput()
    }
    }




  build() {
    Column() {
      Row({ space: 10 }) {
        Image(this.showVoice ? $r("app.media.ic_public_keyboard") : $r("app.media.ic_public_sound"))
          .width(25)
          .height(25)
          .onClick(() => {
            this.showVoice = !this.showVoice
            if (this.showVoice) {
              animateTo({duration:150},()=>{
                this.showBottomCard=false
              })

            }
          })

        if (this.showVoice) {
          Button("按住 说话", {
            type: ButtonType.Normal
          })
            .backgroundColor(Color.White)
            .height(35)
            .layoutWeight(1)
            .borderRadius(2)
            .fontColor($r("app.color.text_primary"))
            .gesture(
              GestureGroup(
                GestureMode.Parallel,
                LongPressGesture()
                  .onAction(()=>{
                    this.checkMicroPhonePermission()
                  })
                  .onActionEnd(()=>{
                    this.releaseFinger()
                  }),
                PanGesture()
                  .onActionUpdate((event)=>{
                    if (event.fingerList[0].globalY>this.screenHeight-120) {

                      this.voiceState=VoiceRecordEnum.RecordIng

                    }else {

                      if (event.fingerList[0].globalX > this.screenWidth / 2) {
                        this.voiceState=VoiceRecordEnum.Transfer
                      }else {
                        this.voiceState=VoiceRecordEnum.Cancel
                      }

                    }
                  })
                  .onActionEnd(()=>{
                    this.voiceState=VoiceRecordEnum.RecordIng
                  })
              )
            )
            .bindContentCover(this.showVoiceCom,this.getVoiceCom,{
              modalTransition:ModalTransition.NONE
            })
        }
        else {
          TextInput({text:$$this.content})
            .layoutWeight(1)
            .height(35)
            .borderRadius(2)
            .backgroundColor(Color.White)
            .id("input")
            .onSubmit(()=>{
              if (this.content) {
                this.sendTextMessage(this.content)
                this.content=""
                focusControl.requestFocus("input")
              }else {
                promptAction.showToast({
                  message:"内容不能为空"
                })
              }
            })
            .onClick(()=>{
              this.showBottomCard=false
            })

        }

        Image($r("app.media.ic_public_add_norm"))
          .width(25)
          .height(25)
          .onClick(()=>{
           animateTo({duration:150},()=>{
             this.showBottomCard=!this.showBottomCard
           })
          })
      }
      .width("100%")
      .height(60)
      .padding({
        left: 10,
        right: 10
      })

        if (this.showBottomCard)
        {
          GridRow({columns:4})
          {
            ForEach(this.bottomList,(item:PopupItem)=>{

              GridCol(){
                this.getBottomCard(item)
              }
            .height(100)
              .onClick(()=>{
                item.itemClick&&item.itemClick()
              })

            })
          }
          .width("100%")
        }

    }
    .backgroundColor($r("app.color.second_back_color"))
  }
}

export default BottomInput