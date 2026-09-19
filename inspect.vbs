Dim fso, swApp, swModel, swFeat, swSubFeat
Set fso = CreateObject("Scripting.FileSystemObject")
Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True
Set swModel = swApp.OpenDoc("D:\etc\WORK\PROJECT DOCUMENT\AUTOMATION BUILD 3D SOLIDWORKS\outputs\JIG-MOT097Z001-0.sldprt", 1)
If swModel Is Nothing Then
    WScript.Echo "OpenDoc6 failed: " & docErrs
    WScript.Quit 1
End If

Set swFeat = swModel.FirstFeature
Do While Not swFeat Is Nothing
    WScript.Echo swFeat.Name & " [" & swFeat.GetTypeName2 & "] Suppressed=" & swFeat.IsSuppressed()
    Set swSubFeat = swFeat.GetFirstSubFeature
    Do While Not swSubFeat Is Nothing
        WScript.Echo "   --> " & swSubFeat.Name & " [" & swSubFeat.GetTypeName2 & "]"
        Set swSubFeat = swSubFeat.GetNextSubFeature
    Loop
    Set swFeat = swFeat.GetNextFeature
Loop
swApp.CloseDoc swModel.GetTitle
WScript.Quit 0
