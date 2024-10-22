import { promptAction, router } from '@kit.ArkUI'
import { getMessageInfo } from '../api/api'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../types/message'
import { currentUser, UserInfo } from '../types/users'
import { StoreClass } from '../utils/StoreClass'
import BottomInput from './BottomInput'
import Message from './Message'
import { emitter } from '@kit.BasicServicesKit'

@Entry
@Component
struct ChatDetail {

  @State
  talkerInputIng:boolean=false

  @State
  talker: UserInfo = {} as UserInfo


  scroller:Scroller=new Scroller()

@State
messageList: MessageInfoModel[] =[]

  dialogController:CustomDialogController=new CustomDialogController({
   builder:this.CustomImageDialog,
   customStyle:true,
   autoCancel:false
 })

  @State
  previewUrl:string=""
  @State
  previewType:MessageTypeEnum=MessageTypeEnum.TEXT

  openCustomImageDialog(filePath:string,type?:MessageTypeEnum){

    this.previewUrl=filePath

    if (type) {
      this.previewType=type

    }
    this.dialogController.open()

  }


  sendTextMessage(content:string){
    let message=new MessageInfoModel({
      messageContent: content,
      sendUser:currentUser,
      connectUser:this.talker
    } as MessageInfo)
    this.messageList.push(message)
    this.getResponseMessage(content)
    StoreClass.addChatMessage(this.talker.user_id,message)
    this.scroller.scrollEdge(Edge.Bottom)
  }

  async getResponseMessage(content:string){
    this.talkerInputIng=true
    try {
      const res=await getMessageInfo(content)
      let message=new MessageInfoModel({
        messageContent:res?.info?.text,
        sendUser:this.talker,
        connectUser:this.talker



      }as MessageInfo)

      this.messageList.push(message)
      this.scroller.scrollEdge(Edge.Bottom)
      this.talkerInputIng=false
      StoreClass.addChatMessage(this.talker.user_id,message)

      promptAction.showToast({
        message:"11212454"
      })

    }catch (e){
      console.log(e)

      promptAction.showToast({
        message:"33333"
      })

    }
  }

  sendImageMessage(filePath:string){

    let message=new MessageInfoModel({
      messageContent:'[图片]',
      sendUser:currentUser,
      connectUser:this.talker,
      sourceFilePath:filePath,
      messageType:MessageTypeEnum.IMAGE
    } as MessageInfo)
    this.messageList.push(message)

    StoreClass.addChatMessage(this.talker.user_id,message)

    this.getResponseMessage("file://"+filePath)

    this.scroller.scrollEdge(Edge.Bottom)

  }

  sendVideoMessage(filePath:string){
    let message=new MessageInfoModel({
      messageContent:'[视频]',
      sendUser:currentUser,
      connectUser:this.talker,
      sourceFilePath:filePath,
      messageType:MessageTypeEnum.VIDEO
    } as MessageInfo)

    this.messageList.push(message)

    StoreClass.addChatMessage(this.talker.user_id,message)

    this.scroller.scrollEdge(Edge.Bottom)

  }

  sendAudioMessage(filePath:string,duration:number){

    let message=new MessageInfoModel({
      messageContent:'[语言]',
      sendUser:currentUser,
      connectUser:this.talker,
      sourceFilePath:filePath,
      messageType:MessageTypeEnum.AUDIO,
      sourceDuration:duration
    } as MessageInfo)

    this.messageList.push(message)

    StoreClass.addChatMessage(this.talker.user_id,message)

    this.scroller.scrollEdge(Edge.Bottom)

  }

  @Builder
  CustomImageDialog(){
    Column(){
      if (this.previewType===MessageTypeEnum.VIDEO){
        Video({
          src:"file://"+this.previewUrl
        })
          .loop(true)
          .autoPlay(true)
          .width("100%")
          .height("100%")
      }else if (this.previewType===MessageTypeEnum.IMAGE){
        Image("file://"+this.previewUrl)
          .width("100%")
          .height("100%")
      }
    }
    .width("100%")
    .height("100%")
    .onClick(()=>{
      this.dialogController.close()
    })
  }



  aboutToAppear(): void {
    this.talker = router.getParams() as UserInfo

    this.messageList=StoreClass.getChatMessage(this.talker.user_id)

  }
  delMessage(id:string){
    const  index=this.messageList.findIndex((item:MessageInfoModel)=>item.id===id)
    this.messageList.splice(index,1)
    emitter.emit(StoreClass.wechat_key)
  }





  build() {
    Column() {


      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text(this.talkerInputIng?"对方正在输入":this.talker.username)
            .width("100%")
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r("app.color.text_primary"))

          Image($r("app.media.ic_public_arrow_left"))
            .width(30)
            .height(30)
            .onClick(() => {
              router.back()
            })
        }
      }
      .height(50)

     List({space:20,scroller:this.scroller}) {
      ForEach(this.messageList,(item:MessageInfoModel)=>{
        ListItem(){
              Message({
                currentMessage:item,
                delMessage:(id:string)=>{
                this.delMessage(id)
                },
                openCustomImageDialog:(filePath:string,type?:MessageTypeEnum)=>{
                  this.openCustomImageDialog(filePath,type)
                }
              })
        }
      })
     }
     .padding({
       top:20,
       bottom:10
     })
      .width("100%")
      .height("100%")
      .layoutWeight(1)
      .backgroundColor($r("app.color.back_color"))

      // 底部输入框
      BottomInput({
        sendTextMessage:(content:string)=>{
          this.sendTextMessage(content)
        },
        sendImageMessage:(filePath:string)=>{
          this.sendImageMessage(filePath)
        },
        sendAudioMessage:(filePath:string,duration:number)=>{
          this.sendAudioMessage(filePath,duration)
        },
        sendVideoMessage:(filePath:string)=>{
          this.sendVideoMessage(filePath)
        },
        talker:this.talker

      })

    }
    .height('100%')
    .width('100%')
  }
}