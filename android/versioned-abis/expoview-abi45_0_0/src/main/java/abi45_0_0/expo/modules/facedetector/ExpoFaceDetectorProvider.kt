package abi45_0_0.expo.modules.facedetector

import android.content.Context
import abi45_0_0.expo.modules.core.interfaces.InternalModule
import abi45_0_0.expo.modules.interfaces.facedetector.FaceDetectorProviderInterface

class ExpoFaceDetectorProvider : FaceDetectorProviderInterface, InternalModule {
  override fun getExportedInterfaces() = listOf(FaceDetectorProviderInterface::class.java)

  override fun createFaceDetectorWithContext(context: Context) = ExpoFaceDetector(context)
}
