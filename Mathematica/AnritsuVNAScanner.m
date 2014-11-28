(* ::Package:: *)

BeginPackage["AnritsuVNAScanner`",{"NETLink`"}]
VNAScanApplet::usage="VNAScan initiates a dialog to take a scan from the Anritsu VNA."
vnaScan::usage="vnaScan[traceSelect,averagingSwitch,averagingFactor,numberPoints,backgroundSubtraction,visaAddress] takes options traceSelect=MagPh/ReIm, averagingSwitch=0/1, integer averagingFactor, numberPoints=51/201/401/801/1601, backgroundSubtraction=0/1, visaAddress default is GPIB0::6::INSTR. Running this initialises a scan on the Anritsu VNA."
vnaFitMagPh::usage="vnaFitMagPh[data,amplitudeGuess] takes the mag/phase data output from vnaScan and performs a fit, giving a plot of the magnitude and phase, the fitting parameters and the q factor."
vnaFitReIm::usage="vnaFitReIm[data,amplitudeGuess] takes the re/im data output from vnaScan and performs a fit, giving a plot of the magnitude and phase, the fitting parameters and the q factor."

Begin["`Private`"]
vnaScan[traceSelect_,avOnOff_,avFac_,numPoints_,visaAddress_:"GPIB0::6::INSTR"]:=Module[{vna,rawData,output,finalOut},
InstallNET["Force32Bit"->True];
LoadNETAssembly["D:\\EDMSuite\\DAQ\\bin\\Sympathetic\\DAQ.dll"];
vna=NETNew[LoadNETType["DAQ.HAL.AnritsuVNA"],visaAddress];
vna@Connect[];
vna@Timeout[];
rawData=If[traceSelect=="ReIm",vna@ReImTrace[avOnOff,avFac,numPoints],vna@MagPhaseTrace[avOnOff,avFac,numPoints]];
output=StringReplace[StringSplit[rawData,";"][[#]],","->"\n"]&/@Range[1,Length[StringSplit[rawData,";"]]];
finalOut=ReadList[StringToStream[output[[#]]],Number]&/@Range[1,Length[output]];
{Transpose[{finalOut[[1]],finalOut[[2]]}],ListPlot[Transpose[{finalOut[[1]],finalOut[[2]]}]],Transpose[{finalOut[[1]],finalOut[[3]]}],ListPlot[Transpose[{finalOut[[1]],finalOut[[3]]}]]}
]
vnaFitMagPh[data_,a_]:=Module[{centralFrequency, rawData,nlmFit,fitParameter,q,linear,phasePlot,phasePlotFit}, 
(*rawData=Import[datapath];*)
linear=Transpose[{data[[1,All,1]],10^(data[[1,All,2]]/10)}];
centralFrequency=data[[Flatten[{Take[Position[data,Max[data[[1,All,2]]]][[1]],2],1}]/.List->Sequence]];
nlmFit=NonlinearModelFit[linear,amplitude/(1+(x-centralFreq)^2/width^2)+offset,{{amplitude,a},{centralFreq,centralFrequency},{width,10^6},{offset,0}},x];
fitParameter=nlmFit["ParameterTableEntries"];
q=fitParameter[[2,1]]/fitParameter[[3,1]]/2;
phasePlot={data[[3,All,1]],data[[3,All,2]]};
(*phasePlotFit=NonlinearModelFit[phasePlot,ArcTan[- amplitude/(x-centralFreq)],{{amplitude,c},{centralFreq,x0}},x];*)
{Show[Plot[nlmFit[x],{x,fitParameter[[2,1]]-5fitParameter[[3,1]],fitParameter[[2,1]]+5fitParameter[[3,1]]},PlotRange->Full,PlotStyle->{Red,Thick},ImageSize->{300,300}],ListPlot[linear,PlotRange->All,PlotStyle->Thick]],nlmFit["ParameterTable"],Show[ListPlot[Transpose[phasePlot],ImageSize->{350,350},PlotRange->All]],q}
]
vnaFitReIm[data_,a_]:=Module[{centralFrequency, rawData,nlmFit,fitParameter,q,linear,phasePlot,phasePlotFit}, 
(*rawData=Import[datapath];*)
linear={data[[1,All,1]],10^(data[[1,All,2]]/10)};
centralFrequency=data[[Flatten[Position[data,Max[data[[All,2]]]]][[1]]]][[1]];
nlmFit=NonlinearModelFit[linear,amplitude/(1+(x-centralFreq)^2/width^2)+offset,{{amplitude,a},{centralFreq,centralFrequency},{width,10^6},{offset,0}},x];
fitParameter=nlmFit["ParameterTableEntries"];
q=fitParameter[[2,1]]/fitParameter[[3,1]]/2;
phasePlot={data[[2,All,1]],data[[2,All,2]]};
(*phasePlotFit=NonlinearModelFit[phasePlot,ArcTan[- amplitude/(x-centralFreq)],{{amplitude,c},{centralFreq,x0}},x];*)
{Show[Plot[nlmFit[x],{x,fitParameter[[2,1]]-5fitParameter[[3,1]],fitParameter[[2,1]]+5fitParameter[[3,1]]},PlotRange->Full,PlotStyle->{Red,Thick},ImageSize->{300,300}],ListPlot[linear,PlotRange->All,PlotStyle->Thick]],nlmFit["ParameterTable"],Show[ListPlot[phasePlot,ImageSize->{350,350},PlotRange->All]],q}
]
VNAScanApplet:=DialogNotebook[{Grid[{{Column[{Row[{"Averaging Factor ",Slider[Dynamic[av],{1,10,1}]," ",Dynamic[av]}],Row[{"Number of points ",Slider[Dynamic[numPoints],{{51,201,401,801,1601}}]," ",Dynamic[numPoints]}],Row[{"Number of scans",PopupMenu[Dynamic[numScans],Range[20]]}]}],Column[{Row[{"Mag/Phase ",Checkbox[Dynamic[magPh]]}],Row[{"Re/Im ",Checkbox[Dynamic[reIm],Enabled->False]}],Row[{"Background subtraction?",Checkbox[Dynamic[bgSub]]}],Row[{"Q only?",Checkbox[Dynamic[qOnly]]}]}]},{Button["Scan",CellPrint[Cell[BoxData[RowBox[{varName,"=",ToBoxes[{If[magPh,vnaFitMagPh[vnaScan["MagPh",If[av==1,0,1],av,numPoints],0.00005][[If[qOnly,-1,All]]]&/@Range[1,numScans]],If[reIm,vnaFitReIm[vnaScan["ReIm",If[av==1,0,1],av,numPoints],0.00005][[If[qOnly,-1,All]]]&/@Range[1,numScans]]}]}]],"Input"]],Method->"Queued"],InputField[Dynamic[varName],String]}}]}];
End[]
EndPackage[]
