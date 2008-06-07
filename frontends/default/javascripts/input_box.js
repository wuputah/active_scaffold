var g_bIgnoreEvent = false;
var g_textCtlCurrent;
/* This was part of QVerifyRankings
var g_textCtlPrev3;
var g_textCtlPrev2;
var g_textCtlNext2;
var g_textCtlNext3;
*/
var g_textCtlPrev;
var g_textCtlNext;
var g_nQuestionId;
var g_szComboItems = new Array();

function AutoTabNum(inputText, strInputNext, str1, str2, str3, strSum) 
{
//	window.status = "|AutoTabNum|"; 
 	var textCtlNext = document.IVForm[strInputNext];
  var strKey;
  var nKeyCode = EventGet();
/*	window.status = window.status + "," + inputText.name + ", Val=" + 
			inputText.value + ", Len=" + inputText.value.length + ", maxLen=" + inputText.maxLength;
*/
	// Ignore everything but integers 48, '0'; 57, '9', Numpad 96, '0'; 105, '9'
	if (((nKeyCode >= 48) && (nKeyCode <= 57)) ||
			((nKeyCode >= 96) && (nKeyCode <= 105)))
	{
		if (inputText.value.length > 0)
		{
			strKey = inputText.value.substring(inputText.value.length - 1, inputText.value.length);
//			window.status = window.status + "," + strKey;
			if (strKey.length > 0)
			{
				if (isNaN(strKey))
				{
					inputText.value = inputText.value.substring(0, inputText.value.length - 1);
				}
				if ((strInputNext.length > 0) && (inputText.value.length >= inputText.maxLength))
				{
					textCtlNext.focus();
					textCtlNext.select();
				}
			}
		}
	}
	document.IVForm[strSum].value = document.IVForm[str1].value + "-" +
													document.IVForm[str2].value + "-" +
													document.IVForm[str3].value;
//	window.status = window.status + ", success";
  return;
}

function CheckDupes(checkBox)
{
 // Check/uncheck any duplicates of the same state in our list
 var name = checkBox.name;
 var checked = checkBox.checked;
 var i = 0;
 var element;
 do {
  element = document.getElementsByName(name)[i];
  if (element)
   element.checked = checked;
  i++;
 } while (element)
}

function ComboSetInput(strInputName, inputCombo) 
{
  var textCtlCurrent = document.IVForm[strInputName];
	
//  window.status = "ComboSetInput|KeyCode: " + event.keyCode + "; " + inputCombo.name + ", " + 	strInputName + ", Cur=" + textCtlCurrent.value;
  textCtlCurrent.value = inputCombo.options[inputCombo.options.selectedIndex].value;
//	window.status = window.status + ", success";
  return;
}

function DashRemove(textElement)
{
	var strTemp = textElement.value; 
	if (strTemp.length > 0)
	{
		for (i=0; i < strTemp.length; i++)  
		{
		 <!--Remove dashes and spaces-->
			if (strTemp.charAt(i) == '-' || strTemp.charAt(i) == ' ')
			{
				strTemp = strTemp.substr(0,i) + strTemp.substr(i + 1);
				i--;
			}
  }
  textElement.value = strTemp
 }
}

function DateDashAdd(textElement)
{
	var strTemp = textElement.value; 
	
	// 11-22-99 or 11-22-1999
	if ((strTemp.length > 0) && 
		 ((strTemp.charAt(2) >= '0') && (strTemp.charAt(2) <= '9')))
	{
   textElement.value = strTemp.substr(0,2) + '/' + strTemp.substr(2,2) + '/' + strTemp.substr(4); 
 }
}

function DateDashAddSm(textElement)
{
	var strTemp = textElement.value; 
	
	// 11-99 or 11-1999
	if ((strTemp.length > 0) && 
		 ((strTemp.charAt(2) >= '0') && (strTemp.charAt(2) <= '9')))
	{
   textElement.value = strTemp.substr(0,2) + '/' + strTemp.substr(2); 
 }
}

function DateCtlMonthFromTo(strInputNameFrom, strInputNameFromSub,strInputNameTo, strInputNameToSub, nMonthAnchor, nMonthOffset) 
{
	var cDate = new Date();
	nMonthAnchor = nMonthAnchor * 28;
	if (nMonthAnchor != 0)
	{
		cDate.setDate(nMonthAnchor);
	}
	cDate.setDate(1);
//	cDate.setMonth(nMonthFrom - 1);
//alert("From=" + nMonthAnchor + ":" + cDate.getMonth() + "-" + cDate.getDate() + "-" + cDate.getFullYear() + ":" + document.IVForm[strInputNameFromSub + 'Month'].value);
	DateCtlMonthSet(strInputNameFrom, strInputNameFromSub, cDate); 
//	cDate.setMonth(nMonthTo);
	cDate.setMonth(cDate.getMonth() + nMonthOffset);
	cDate.setDate(cDate.getDate() - 1);
//alert("To=" + cDate.getMonth() + "-" + cDate.getDate() + "-" + cDate.getFullYear() + ":" + document.IVForm[strInputNameFromSub + 'Month'].value);
	DateCtlMonthSet(strInputNameTo, strInputNameToSub, cDate);
	return;
}

function DateCtlMonthFromToCurrentYear(strInputNameFrom, strInputNameFromSub,strInputNameTo, strInputNameToSub) 
{
	var cDate = new Date();
	var cDate1 = new Date();
	DateCtlMonthSet(strInputNameTo, strInputNameToSub, cDate1);
	for (var i = 0; i < 12; i++)
	{
		cDate.setDate(1);
		cDate.setDate(cDate.getDate() - 1);
	}
	cDate.setDate(cDate1.getDate());
	DateCtlMonthSet(strInputNameFrom, strInputNameFromSub, cDate); 
	return;
}

function DateCtlMonthFromToYTD(strInputNameFrom, strInputNameFromSub,strInputNameTo, strInputNameToSub) 
{
	var cDate = new Date();
	DateCtlMonthSet(strInputNameTo, strInputNameToSub, cDate);
	cDate.setDate(1);
	cDate.setMonth(0);
	DateCtlMonthSet(strInputNameFrom, strInputNameFromSub, cDate); 
	return;
}

function DateCtlMonthSet(strInputName, strInputNameSub, cDate) 
{
	SetComboDate(strInputNameSub + 'Month', cDate.getMonth() + 1);
	SetComboDate(strInputNameSub + 'Day', cDate.getDate());
	SetComboDate(strInputNameSub + 'Year', cDate.getFullYear());
	DateCtlValidate(strInputName, strInputNameSub);
	return;
}

function DateCtlValidate(strInputName, strInputNameSub) 
{
  var textDateCtl = document.IVForm[strInputName];	
  var textDateCtlMonth = document.IVForm[strInputNameSub + 'Month'];
  var textDateCtlDay = document.IVForm[strInputNameSub + 'Day'];
  var textDateCtlYear = document.IVForm[strInputNameSub + 'Year'];
  var textDateCtlHour = document.IVForm[strInputNameSub + 'Hour'];
  var textDateCtlMin = document.IVForm[strInputNameSub + 'Min'];
  var textDateCtlSec = document.IVForm[strInputNameSub + 'Sec'];
  var textDateCtlAMPM = document.IVForm[strInputNameSub + 'AMPM'];
	textDateCtl.value = textDateCtlMonth.value + '-' + textDateCtlDay.value + '-' + textDateCtlYear.value;
	if (textDateCtlHour != null)
	{
		textDateCtl.value += ' ' + textDateCtlHour.value + ':' + textDateCtlMin.value;
		if (textDateCtlSec != null)
		{
			textDateCtl.value += ':' + textDateCtlSec.value;
		}
		textDateCtl.value += ' ' + textDateCtlAMPM.value;
	}
	return;
}

function EmailText(strEmailTo, strSubject, strBody) 
{
	var strMail = "mailto:" + document.IVForm[strEmailTo].value + "?Subject=" + strSubject + "&Body=" + document.IVForm[strBody].value;
	
//	alert(strMail);
	window.location = strMail;
}

function EventGet() 
{
  var nKeyCode = event.keyCode ? event.keyCode :
                event.charCode ? event.charCode :
                event.which ? event.which : void 0;
/*
	window.status = window.status + "Key=" + nKeyCode + "," + 
									"KeyC=" + event.keyCode + "," + 
									"CharC=" + event.charCode + "," + 
									"Which=" + event.which;
*/
	return nKeyCode;
}

function FocusToFirstField() 
{
	var nIndex = -1, i = 0, bFound = false;
	
	while ((i < document.IVForm.length) && !bFound)
	{
		if (!document.IVForm[i].disabled && document.IVForm[i].type != "hidden")
		{
//alert(document.IVForm[i].name);
			nIndex = i;
			bFound = true;
		}
		else 
			i++;
	}
	if (bFound)
		document.IVForm[nIndex].focus();
	return false;
}

function FocusToFirstEditField(strNameBase) 
{
	var nIndex = -1, i = 0, bFound = false;
	
	while ((i < document.IVForm.length) && !bFound)
	{
		if (!document.IVForm[i].disabled && document.IVForm[i].type != "hidden" && (document.IVForm[i].name.indexOf(strNameBase) > -1))
		{
//alert(document.IVForm[i].name);
			nIndex = i;
			bFound = true;
		}
		else 
			i++;
	}
	if (bFound)
	{
		document.IVForm[nIndex].focus();
		document.IVForm[nIndex].select();
	}
	return false;
}

function InputComboValidate(inputText, strComboName) 
{
 	var comboCtlCurrent = document.IVForm[strComboName];
//  window.status = "IComboVal|KeyCode: " + event.keyCode + "; " + strComboName + ", " + ", Cur=" + inputText.value;
	if (inputText.value.length > 0)
	{
		// Synchronize with the corresponding radio button
		if (comboCtlCurrent)
		{
			var optionCtl = comboCtlCurrent.options;
			var strValue = inputText.value;
			// If it is a number, remove the leading zeros for the comparison
			if (parseInt(strValue, 10))
			{
				strValue = parseInt(strValue, 10);
			}
//window.status = window.status + ", strValue =" + strValue;
//			var nPad = inputText.maxLength - strValue.length;
//window.status = window.status + ", strValue.length =" + strValue.length;
//window.status = window.status + ", inputText.maxLength =" + inputText.maxLength;
/*No longer use Add leading zeros
			for (var j = 0; j < nPad; j++)
			{
				strValue = "0" + strValue;
			}
*/
// This doesn't work in Safari			for (var i = 0; i < optionCtl.options.length; i++) 
			var i;
			i = 0;
			while (optionCtl[i])
			{
				if (optionCtl[i].value == strValue)
				{
					optionCtl[i].selected = true;
					break;
				}
				i++;
			}
		}
	}
//	window.status = window.status + ", success";
  return ;
}

function InputComboSync(strComboNameParent, strComboNameChild) 
{
 	var comboCtlCurrentParent = document.IVForm[strComboNameParent];
 	var comboCtlCurrentChild = document.IVForm[strComboNameChild];
	if (comboCtlCurrentChild)
	{
//alert (comboCtlCurrentParent.value);
		var szComboItems = g_szComboItems[comboCtlCurrentParent.value];
		for ( var nOption = 0, nItems = 0; nItems < szComboItems.length; nOption++, nItems +=2 )
		{
			comboCtlCurrentChild.options[nOption] = new Option(szComboItems[nItems], szComboItems[nItems+1] );
		}
		comboCtlCurrentChild.options.length = nOption;
		comboCtlCurrentChild.selectedIndex = 0;
		return ;
	}
}

function MoneySigns(textElement)
{
	var strAmount = NumberCleanUp(textElement.value);
	if (strAmount.length == 0)
	{
		textElement.value = '';
	}
	else
	{
		strAmount = NumberToDollar(strAmount, ",");
		if (strAmount.length == 0)
		{
			textElement.value = '';
		}
		else
		{
			textElement.value = strAmount;
		}
	}
}

function NumberToDollar(amount, CommaDelimiter)
{
	try 
	{
		
		amount = parseFloat(amount);
		var samount = new String(amount);
		var decimal = '';
		if (samount.indexOf(".") >= 0)
		{
			decimal = samount.substr(samount.length-3,3);
			samount = samount.substr(0, samount.length-3);
//alert(samount + " : " + decimal);
		}
		for (var i = 0; i < Math.floor((samount.length-(1+i))/3); i++)
		{
			 samount = samount.substring(0,samount.length-(4*i+3)) + CommaDelimiter + samount.substring(samount.length-(4*i+3));
		 }
		 samount += decimal;		
	}
	catch (exception) { AlertError("Format Comma",e); }
	return samount;
}

function PermissionValidate(strInputName, nSub) 
{
	var strValue = '';
	for (i = 1; i <= nSub; i++)
	{
		strName = strInputName + i;
		if (document.IVForm[strName].type == "hidden")
		{
//alert ("__" + strName);
			if (document.IVForm["__" + strName].checked)
				strValue += document.IVForm[strName].value;
		}
		else if (document.IVForm[strName].type == "select-one")
		{
			strValue += document.IVForm[strName].value;
		}
//alert (strValue);
	}
	document.IVForm[strInputName].value = strValue;	
	return;
}

// Assumes to be used OnKeyPress
function OnKeyPressEnter(inputText, strTextNext) 
{
//	window.status = "|OnKeyPressEnter|";
  var nKeyCode = EventGet();
	if (g_bIgnoreEvent)
	{
		g_bIgnoreEvent = false;
		return false;
	}
	if ((nKeyCode == 13) || // Enter, then tab
			(nKeyCode == 3)) 	// Enter on 10 key pad on eMacs, then tab
	{
		var nIndex = -1, i = 0, bFound = false;
		
		while ((i < inputText.form.length) && !bFound)
		{
			if ((inputText.form[i] == inputText))
			{
				// Found the current field
				i++; // Move to the next field
				// Find the next text field
				while ((i < inputText.form.length) && !bFound)
				{
					if ((inputText.form[i].type != 'select-one') && (!inputText.form[i].disabled))
					{
//alert(inputText.form[i].type + ":" + inputText.form[i].name);
						nIndex = i;
						bFound = true;
					}
					else 
						i++;
				}
			}
			else 
				i++;
		}
		inputText.form[(nIndex) % inputText.form.length].focus();
		return false;
		
//		var textCtlNext = document.IVForm[strTextNext];
//		if (textCtlNext)
//		{
//			textCtlNext.focus();
//			textCtlNext.select();
////			g_bIgnoreEvent = true;
//			return false;
//		}
	}
}

// Assumes OnKeyDown
function OnKeyDownBkspc(inputText, strTextPrev) 
{
//	window.status = "|OnKeyDownBkspc|";
  var nKeyCode = EventGet();
	if (g_bIgnoreEvent)
	{
		g_bIgnoreEvent = false;
		return false;
	}
	if (nKeyCode == 8) // Backspace, the backtab
	{
		var textCtlPrev = document.IVForm[strTextPrev];
		if (textCtlPrev && (inputText.value.length == 0))
		{
			textCtlPrev.focus();
			textCtlPrev.select();
//			g_bIgnoreEvent = true;
			return false;		
		}
	}
}

function QEventGet(nQuestionId, nQuestionIdPrev, nQuestionIdNext) 
{
	var bAll = false;
	var nKeyCode = EventGet();
  var strTextCtl = "textQuestionId";  
//	if (g_nQuestionId == nQuestionId)
//	{
//		return nKeyCode;
//	}
	g_textCtlCurrent = document.IVForm[strTextCtl + nQuestionId];
	if (nQuestionIdPrev)
		g_textCtlPrev = document.IVForm[strTextCtl + nQuestionIdPrev];
	if (nQuestionIdNext)
		g_textCtlNext = document.IVForm[strTextCtl + nQuestionIdNext];
//	alert( ", QID=" + nQuestionIdPrev + ", Cur=" + g_textCtlPrev.value + ", QID=" + nQuestionIdNext + ", Cur=" + g_textCtlNext.value);
	return nKeyCode;
//	window.status = window.status + ", QID=" + nQuestionId + ", Cur=" + g_textCtlCurrent.value + ":" + g_bIgnoreEvent;
/* This was part of QVerifyRankings
	if ((nQuestionId != 3) && bAll)
	{
		g_textCtlPrev3 = document.IVForm[strTextCtl + (nQuestionId - 3)];
	}
	if ((nQuestionId != 2) && bAll)
	{
		g_textCtlPrev2 = document.IVForm[strTextCtl + (nQuestionId - 2)];
	}
	if (nQuestionId != 1)
	{
		g_textCtlPrev = document.IVForm[strTextCtl + (nQuestionId - 1)];
	}
	if (document.IVForm[strTextCtl + (nQuestionId + 1)]) //nQuestionId != 102)
	{
		g_textCtlNext = document.IVForm[strTextCtl + (nQuestionId + 1)];
	}
	if (document.IVForm[strTextCtl + (nQuestionId + 2)] && bAll)//(nQuestionId != 101) && bAll)
	{
		g_textCtlNext2 = document.IVForm[strTextCtl + (nQuestionId + 2)];
	}
	if (document.IVForm[strTextCtl + (nQuestionId + 3)] && bAll)//(nQuestionId != 100) && bAll)
	{
		g_textCtlNext3 = document.IVForm[strTextCtl + (nQuestionId + 3)];
	}
//window.status = window.status + "," + nKeyCode;
	return nKeyCode;
*/
}

// Assumes to be used OnKeyDown
function QOnKeyDownBack(nQuestionId, nQuestionIdPrev, nQuestionIdNext) 
{
//	window.status = "|QOnKeyDownBack|";
	if (g_bIgnoreEvent)
	{
//		g_bIgnoreEvent = false;
		return true;
	}
  var nKeyCode = QEventGet(nQuestionId, nQuestionIdPrev, nQuestionIdNext);
//window.status = window.status + ":" + g_bIgnoreEvent + ",0";
	if (nKeyCode == 8) // Backspace simulate back-tab;
	{
//window.status = window.status + ",1";
		if ((g_textCtlCurrent.value.length == 0) && (g_textCtlPrev))	
		{
//window.status = window.status + ",2";
			g_textCtlPrev.focus();
			g_textCtlPrev.select();
//window.status = window.status + ",3";
			g_bIgnoreEvent = true;
//			return false; // Tell it to ignore everything from this point on
		}
	}
	return true;
}

// Assumes to be used OnKeyPress
function QOnKeyPressBack(nQuestionId, nQuestionIdPrev, nQuestionIdNext) 
{
	return true;
//	window.status = window.status + "|QOnKeyPressBack|";
	if (g_bIgnoreEvent)
	{
//		g_bIgnoreEvent = false;
		return true;
	}
  var nKeyCode = QEventGet(nQuestionId, nQuestionIdPrev, nQuestionIdNext);
//window.status = window.status + ",0";
	if (nKeyCode == 43)// || (nKeyCode == 107))// + simulate back-tab;
	{
//window.status = window.status + ",1";
		if (g_textCtlPrev)		
		{
//window.status = window.status + ",2";
			g_textCtlPrev.focus();
			g_textCtlPrev.select();
//window.status = window.status + ",3";
			g_bIgnoreEvent = true;
			return false; // Tell it to ignore everything from this point on
		}
	}
	return true;
}

// Show the current question in the combo box
function QShow(nQuestionId) 
{
	if (document.IVForm["QuestionID"])
	{
		var optionCtl = document.IVForm["QuestionID"].options;
				optionCtl[nQuestionId-1].selected = true;
/*		for (var i = 0; i < optionCtl.length; i++) 
		{
			if (optionCtl[i].value == nQuestionId)
			{
				optionCtl[i].selected = true;
				break;
			}
		}
*/
	}
}

function QVerifyRadioSet(strValue, nQuestionId, nUpperLimit) 
{
	var radioCtlCurrent = document.IVForm["radioQuestionId" + nQuestionId];
	var nRadioValue;
	var nRadioIndex;

//	window.status = window.status + "|QRad|" + nQuestionId + ", Val=" + strValue;
	if (radioCtlCurrent)
	{
		if (strValue.length)
		{
			//Set appropriate radio button
			nRadioIndex = 0;
			//We can't rely on the order
			for (var i=0; i < nUpperLimit; i++)// in document.IVForm.radioCtlCurrent)// 
			{
				nRadioValue = radioCtlCurrent[i].value;
				// Find the radio to check
//				window.status = window.status + "," + i + ":";
				if (strValue == nRadioValue)
				{
					nRadioIndex = i + 1;
					break;
				}
			}
			//Don't know why but this doesn't work 
			//				if (nRadioIndex > 0)
			//				  radioCtlCurrent[nRadioIndex - 1].checked = true;
//			window.status = window.status + ",radioI" + nRadioIndex;
			//So we do this...
			if (nRadioIndex == 1)
				radioCtlCurrent[0].checked = true;
			else if (nRadioIndex == 2)
				radioCtlCurrent[1].checked = true;
			else if (nRadioIndex == 3)
				radioCtlCurrent[2].checked = true;
			else if (nRadioIndex == 4)
				radioCtlCurrent[3].checked = true;
			else if (nRadioIndex == 5)
				radioCtlCurrent[4].checked = true;
			else if (nRadioIndex == 6)
				radioCtlCurrent[5].checked = true;
		}
		else
		{
//			window.status = window.status + "None";
			//Clear the radio group
			radioCtlCurrent[0].checked = true;
			radioCtlCurrent[0].checked = false;
		}
	}
}

/* 
function QVerifyRankings(strValue, nQuestionId, strQuestionNumber) 
{
	// If it is a ranked item make sure each ranking is unique
	if ((strQuestionNumber >= "a") && (strQuestionNumber <= "d") && (strValue != "0"))
	{
		var bSame = 0;			
		
		if (strQuestionNumber == "d")
		{
			if (g_textCtlPrev3.value == strValue)
			{
				bSame = 1;
			}
		}
		if ((strQuestionNumber == "c") || (strQuestionNumber == "d"))
		{
			if (g_textCtlPrev2.value == strValue)
			{
				bSame = 1;
			}
		}
		if ((strQuestionNumber == "b") || (strQuestionNumber == "c") || (strQuestionNumber == "d"))
		{
			if (g_textCtlPrev.value == strValue)
			{
				bSame = 1;
			}
		}
		if ((strQuestionNumber == "a") || (strQuestionNumber == "b") || (strQuestionNumber == "c"))
		{
			if (g_textCtlNext.value == strValue)
			{
				bSame = 1;
			}
		}
		if ((strQuestionNumber == "a") || (strQuestionNumber == "b"))
		{
			if (g_textCtlNext2.value == strValue)
			{
				bSame = 1;
			}
		}
		if (strQuestionNumber == "a")
		{
			if (g_textCtlNext3.value == strValue)
			{
				bSame = 1;
			}
		}
		if (bSame > 0)
		{
			strValue = "";
		}
	} // each ranking is unique
	return strValue;
}
*/

function QVerify(nQuestionId, nQuestionIdPrev, nQuestionIdNext, strQuestionNumber, nLowerLimit, nUpperLimit) 
{
//	window.status = window.status + "|QVerify|";
	var bNewValue = 0;
	var strValue;
	if (g_bIgnoreEvent)
	{
		g_bIgnoreEvent = false;
//		window.status = window.status + ", ignored.";
		return false; // Tell it to ignore everything from this point on
	}
  var nKeyCode = QEventGet(nQuestionId, nQuestionIdPrev, nQuestionIdNext);
	strValue = g_textCtlCurrent.value; 
	if ((((nKeyCode >= 48) && (nKeyCode <= 57)) ||
			((nKeyCode >= 96) && (nKeyCode <= 105))) && (strValue.length > 0))
	{
		bNewValue = 1;
	}
		// Check if value is valid
	if (strValue.length > 0)
	{
		if (isNaN(strValue) || (strValue < nLowerLimit) 
				|| (strValue > nUpperLimit))
		{
			strValue = "";
			g_textCtlCurrent.value = strValue;
		}
/* It is OK to give two answers the same ranking if via the call center. I don't know if we will want to turn this on for the online applicant scoring?
		else
		{
			strValue = QVerifyRankings(strValue, nQuestionId, strQuestionNumber);
		}
*/
	}
	QVerifyRadioSet(strValue, nQuestionId, nUpperLimit);
	// If valid move to the next control
	if (bNewValue == 1)
	{
		g_textCtlCurrent.value = strValue;
		if (strValue.length == 0)
		{
			document.getElementById("td" + nQuestionId).bgColor = "red";
		}
		else
		{
			document.getElementById("td" + nQuestionId).bgColor = "white";
			if ((g_textCtlNext) && (strValue.length > 0))
			{
				if (g_textCtlNext.value.length > 0)
				{
// This is only necessary in OSX
//					g_bIgnoreEvent = true; 
				}
				g_textCtlNext.focus();
				g_textCtlNext.select();
			}
		}
	}
//	window.status = window.status + ", end";
  return true;
}

function SetCombo(strComboName, strValue) 
{
 	var comboCtlCurrent = document.IVForm[strComboName];
//	alert("SetCombo:" + strComboName + ":" + comboCtlCurrent.value + ":" + strValue);
	if (strValue)
	{
		// Synchronize with the corresponding radio button
		if (comboCtlCurrent != null)
		{
			var optionCtl = comboCtlCurrent.options;
// This doesn't work in Safari			for (var i = 0; i < optionCtl.options.length; i++) 
			var i;
			i = 0;
			while (optionCtl[i])
			{
				if (optionCtl[i].value == strValue)
				{
					optionCtl[i].selected = true;
					break;
				}
				i++;
			}
		}
	}
  return ;
}

function SetComboDate(strComboName, strValue) 
{
	if (strValue < 10)
	{
		strValue = "0" + strValue;
	}
	SetCombo(strComboName, strValue); 
//alert("Combodate:" + strComboName + ":" + strValue);
  return ;
}

function SetTextCtl(nQuestionId, nValue) {
  var textCtlCurrent = document.IVForm["textQuestionId" + nQuestionId];
	
	textCtlCurrent.value = nValue;
  return;
}

function SetTextInputCtl(strInputName, nValue, strNameSliderBase, nLowerLimit, nUpperLimit) 
{
  var textCtlCurrent = document.IVForm[strInputName];	
	textCtlCurrent.value = nValue;
	SetSliderInputCtl(strNameSliderBase, nValue, nLowerLimit, nUpperLimit);
  return;
}

function SetIVFormField(strFieldName, strFieldValue)
{
	if (strFieldName.length > 0)
	{
		if (document.IVForm['_' + strFieldName])
		{
			document.IVForm['_' + strFieldName].value = strFieldValue;
//			alert('_' + strFieldName + ":" + strFieldValue);
		}
		if (document.IVForm[strFieldName])
		{
			document.IVForm[strFieldName].value = strFieldValue;
//			alert(strFieldName + ":" + strFieldValue);
		}
	}
}

function SsnDashAdd(textElement)
{
	var strTemp = textElement.value; 
	if ((strTemp.length > 0) && 
		 ((strTemp.charAt(3) >= '0') && (strTemp.charAt(3) <= '9')))
	{
		textElement.value = strTemp.substr(0,3) + '-' + strTemp.substr(3,2) + '-' + strTemp.substr(5); 
 }
}

function InProgress()
{
	if (!g_bSubmitted)
	{
		document.getElementById("DivForm").style.visibility = 'hidden';
		document.getElementById("DivForm").style.display = 'none';
		document.getElementById("DivInProcess").style.visibility = 'visible';
		document.getElementById("DivInProcess").style.display = 'inline';
//		var styleObject = getStyleObject("DivForm");
//
//		if(styleObject) 
//			styleObject.visibility = "hidden";

//		cDiv = eval("document.all."+"DivForm");
//		cDiv.style.visibility = "hidden";
//		cDif.style.display = "none";
//		document.IVForm["DivForm"].style.visibility = "hidden";
//		document.IVForm["DivForm"].style.display = "none";
	}
}

var g_bSubmitted = false;
function Submit()
{
	document.IVForm.target = '_self';
	document.IVForm.submit();
	g_bSubmitted = true;
}

function SubmitOnce(button)
{
	if (!g_bSubmitted)
	{
		Submit();
		if (button)
		{
			button.disabled = 1;
		}
	}
}

function SubmitIVForm(strMenuAction)
{
	SubmitIVFormField(strMenuAction, "", "");
}

function SubmitIVFormField(strMenuAction, strFieldName, strFieldValue)
{
	document.IVForm['_MenuAction'].value = strMenuAction;
	if (document.IVForm['MenuAction'])
	{
		document.IVForm['MenuAction'].value = strMenuAction;
	}
	SetIVFormField(strFieldName, strFieldValue);
	Submit();
}

function SubmitIVFormField2(strMenuAction, strFieldName, strFieldValue, strFieldName2, strFieldValue2)
{
	SetIVFormField(strFieldName2, strFieldValue2);
	SubmitIVFormField(strMenuAction, strFieldName, strFieldValue);
}

function SubmitIVFormField3(strMenuAction, strFieldName, strFieldValue, strFieldName2, strFieldValue2, strFieldName3, strFieldValue3)
{
	SetIVFormField(strFieldName3, strFieldValue3);
	SetIVFormField(strFieldName2, strFieldValue2);
	SubmitIVFormField(strMenuAction, strFieldName, strFieldValue);
}

function SubmitIVFormInfo(strMenuAction, strResultID)
{
	SetIVFormField('ResultID', strResultID);
	if (strResultID)
	{
		SetIVFormField('Edit', 1);
	}
	else
	{
		SetIVFormField('Edit', '');
	}
	SubmitIVForm(strMenuAction);
}

function SubmitIVFormReport(strMenuAction, strReportAction, strReportView, strReportType)
{
	SetIVFormField('ReportAction', strReportAction);
	SetIVFormField('ReportType', strReportType);
	SetIVFormField('ReportView', strReportView);
	SubmitIVForm(strMenuAction);
}

function SubmitIVFormScenario(strMenuAction, strScenario)
{
	SubmitIVFormField(strMenuAction, 'Scenario', strScenario);
}

function SubmitIVFormSql(strMenuAction, strSqlAction)
{
	SetIVFormField('SqlAction', strSqlAction);
	SubmitIVForm(strMenuAction);
}

function SubmitIVFormTest(strMenuAction, bDetail)
{
	document.IVForm['_TestEntryView'].value = bDetail;
	if (document.IVForm['TestEntryView'])
	{
		document.IVForm['TestEntryView'].value = bDetail;
	}
	SubmitIVForm(strMenuAction);
}

function TerminateTest(nMenuItem) 
{
	alert("You have exceeded the maximum allowed time to complete the test.");
	SubmitIVForm(nMenuItem);
}

function TerminateWarning(nMinutes) 
{
	alert("You have " + nMinutes + " minutes to complete the test.");
}

function TextVerify(textCtlCurrent, strTextNext, nLowerLimit, nUpperLimit, strNameRadioBase) 
{
//	window.status = "|TextVerify|";
	var bNewValue = 0;
	var strValue;
  var nKeyCode = EventGet();
	if (g_bIgnoreEvent)
	{
		g_bIgnoreEvent = false;
//		window.status = window.status + ", ignored.";
		return false;
	}
	strValue = textCtlCurrent.value; 
	// 109 and 189 are the '-'
	if ((nKeyCode == 189) || (nKeyCode == 109))
	{
		return false;
	}
	else if ((((nKeyCode >= 48) && (nKeyCode <= 57)) ||
			((nKeyCode >= 96) && (nKeyCode <= 105))) && (strValue.length > 0))
	{
		bNewValue = 1;
	}
		// Check if value is valid
	if (strValue.length > 0)
	{
		if (isNaN(strValue) || (parseInt(strValue) < nLowerLimit) 
				|| (parseInt(strValue) > nUpperLimit))
		{
			strValue = "";
			textCtlCurrent.value = strValue;
		}
	}
	VerifyRadioSet(strValue, strNameRadioBase, nUpperLimit);
	SetSliderInputCtl(strNameRadioBase, parseInt(strValue), nLowerLimit, nUpperLimit);
// If valid move to the next control
	if (bNewValue == 1)
	{
		textCtlCurrent.value = strValue;
		if (strValue.length == 0)
		{
			document.getElementById(strTextCtl).bgColor = "red";
		}
		else
		{
			document.getElementById(strTextCtl).bgColor = "white";
			if (strTextNext)
			{
				var textCtlNext = document.IVForm[strTextNext];
				if ((textCtlNext) && (strValue.length > 0))
				{
					if (textCtlNext.value.length > 0)
					{
	// This is only necessary in OSX
	//					g_bIgnoreEvent = true; 
					}
					textCtlNext.focus();
					textCtlNext.select();
				}
			}
		}
	}
//	window.status = window.status + ", end";
  return false;
}

function ToggleCheckValue(objCheck) 
{
	var strCheckValName = objCheck.name;
	var strWhichCheck = strCheckValName.substring(2, strCheckValName.length);
	var objForm = objCheck.form;
	
	if (objForm[strCheckValName].checked)
		objForm[strWhichCheck].value = 1;
	else
		objForm[strWhichCheck].value = "0.0"; // This is the only way to get g_dC->Cancel_b to uncancel. It will be unnecessary once we get rid of the Read_REQUEST mess.
//alert(strWhichCheck + "," + objForm[strWhichCheck].value);
}

function ToUpper(textElement)
{
	var strTemp = textElement.value; 
   textElement.value = strTemp.toUpperCase(); 
}

function VerifyRadioSet(strValue, strRadioBase, nUpperLimit) 
{
	var radioCtlCurrent = document.IVForm[strRadioBase];
	var nRadioValue;
	var nRadioIndex;

//	window.status = window.status + "|VRadioSet|" + strRadioBase + ", Val=" + strValue;
	if (radioCtlCurrent)
	{
		if (strValue.length)
		{
			//Set appropriate radio button
			nRadioIndex = 0;
			//We can't rely on the order
			for (var i=0; i < nUpperLimit && i < radioCtlCurrent.length; i++)
			{
				nRadioValue = radioCtlCurrent[i].value;
				// Find the radio to check
//				window.status = window.status + "," + i + ":";
				if (strValue == nRadioValue)
				{
					nRadioIndex = i + 1;
					break;
				}
			}
			//Don't know why but this doesn't work 
			//				if (nRadioIndex > 0)
			//				  radioCtlCurrent[nRadioIndex - 1].checked = true;
//			window.status = window.status + ",radioI" + nRadioIndex;
			//So we do this...
			if (nRadioIndex == 1)
				radioCtlCurrent[0].checked = true;
			else if (nRadioIndex == 2)
				radioCtlCurrent[1].checked = true;
			else if (nRadioIndex == 3)
				radioCtlCurrent[2].checked = true;
			else if (nRadioIndex == 4)
				radioCtlCurrent[3].checked = true;
			else if (nRadioIndex == 5)
				radioCtlCurrent[4].checked = true;
			else if (nRadioIndex == 6)
				radioCtlCurrent[5].checked = true;
		}
		else
		{
//			window.status = window.status + "None";
			//Clear the radio group
			radioCtlCurrent[0].checked = true;
			radioCtlCurrent[0].checked = false;
		}
	}
}

function WarningPopUp()
{
	var popurl="warning.htm"
	winpops = window.open(popurl,"","width=400,height=200,")
}

function WindowClose(message)
{ 
	var truthBeTold = window.confirm(message + " Click OK to close. Click Cancel to leave window open.");
	if (truthBeTold) 
		window.close();
}

var myPopWin;
function WindowPopOpen()
{ 
	myPopWin = open("http://www.google.com","hoverwindow","width=300,height=200,left=,top=");
	
	// open new document 
	myPopWin.document.open();
	
	// Text of the new document
	// Replace your " with ' or \" or your document.write statements will fail
	myPopWin.document.write("<html><title>JavaScript New Window</title>");
	myPopWin.document.write("<body bgcolor=\"#FFFFFF\">");
	myPopWin.document.write("This is a new html document created by JavaScript ");
	myPopWin.document.write("statements contained in the previous document.");
	myPopWin.document.write("<br>");
	myPopWin.document.write("</body></html>");
	
	// close the document
	myWin.document.close(); 
}

function WindowPopClose()
{ 
	if (!myPopWin.closed)
		myPopWin.close();
}
