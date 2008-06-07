function NukeBadChars(textElement)
{
 var strTemp = textElement.value;
 
	for (i=0; i < strTemp.length; i++)  
	{
	 if (
	  (strTemp.charAt(i) == "'") || 
	  (strTemp.charAt(i) == '"'))
		{
			strTemp = strTemp.substr(0,i) + strTemp.substr(i + 1);
			i--;
		}
 }
 textElement.value = strTemp
}

function NumberCleanUp(num)
{
	var sVal='';
	var nVal = num.length;
	var sChar='';
	// First 
 	try
	{
		for(i = 0 ; i < nVal; i++)
		{
			sChar = num.charAt(i);
			nChar = sChar.charCodeAt(0);
			if (sChar =='.')
			{
//alert('here');
					sVal += num.charAt(i);   
//					i = nVal; // Done
			}
			else if ((nChar >=48) && (nChar <=57))  
			{ 
				sVal += num.charAt(i);   
			}
		}
	}
	catch (exception) { AlertError("Format Clean",e); }
	return sVal;
}

function PercentageFormat(textElement)
{
	var strTemp = textElement.value; 
	var szTemp = strTemp.split(".");
	
  if (szTemp.length > 1)
  {  
    textElement.value = NumberCleanUp(szTemp[0]) + "." + NumberCleanUp(szTemp[1]) + "%";
  }
  else
  {  
    textElement.value = NumberCleanUp(szTemp[0]) + "%";
  }
}

function UsaPhoneDashAdd(textElement)
{
	var strTemp = textElement.value; 
	strTemp = NumberCleanUp(textElement.value);
	if (strTemp)
	{
		textElement.value = strTemp.substr(0,3) + '-' + strTemp.substr(3,3) + '-' + strTemp.substr(6); 
	}
}

function UsaZipDashAdd(textElement)
{
	var strTemp = textElement.value; 
	strTemp = NumberCleanUp(textElement.value);
	if (strTemp.length > 5)
	{
		textElement.value = strTemp.substr(0,5) + '-' + strTemp.substr(5); 
	}
}

function UsaMoney(textElement)
{
	var negChar = '';	
	//if this is a negative number add it back after we are done formatting.		
	if (textElement.value.indexOf("-") >= 0)
	{
		negChar = '-';
	}
	var strAmount = NumberCleanUp(textElement.value);
	if (strAmount.length == 0)
	{
		textElement.value = '';
	}
	else
	{
		strAmount = NumberDelimeterAdd(strAmount, ",");
		if (strAmount.length == 0)
		{
			textElement.value = '';
		}
		else
		{
			textElement.value = negChar + "$" + strAmount;
		}
	}
}

function UsaNumberDelimeterAdd(textElement)
{
	var strAmount = NumberCleanUp(textElement.value);
	if (strAmount.length == 0)
	{
		textElement.value = '';
	}
	else
	{
		strAmount = NumberDelimeterAdd(strAmount, ",");
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

function NumberDelimeterAdd(amount, CommaDelimiter)
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
