import { fileIo } from "@kit.CoreFileKit"


export  class FileOperate{

  static createAudioFile(userId:string){

    const  dirPath=getContext().filesDir+"/"+userId

    const flag=fileIo.accessSync(dirPath)

    if(!flag){
      fileIo.mkdirSync(dirPath)
    }

    let  filePath=dirPath+"/"+Date.now()+".wav"

    const file=fileIo.openSync(filePath,fileIo.OpenMode.CREATE)

    fileIo.closeSync(file)

    return filePath
  }

  static delFilePath(filePath:string){
    if (filePath) {
      fileIo.unlinkSync(filePath)
    }
  }

  static delUserPath(userId:string){
    if (userId) {
      const dirPath=getContext().filesDir+"/"+userId
      const flag=fileIo.accessSync(dirPath)
      if (flag) {
        fileIo.rmdirSync(dirPath)
      }
    }
  }



}









