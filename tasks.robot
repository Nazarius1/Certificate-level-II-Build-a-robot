*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.RobotLogListener
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Desktop
Library           RPA.Tables
Library           RPA.Excel.Files
Library           RPA.Dialogs
Library           csvLibrary.py
Library           RPA.Tables
Library           OperatingSystem
Library           RPA.Dialogs
Library           RPA.FileSystem
Library           RPA.JavaAccessBridge
Library           RPA.PDF
Library           RPA.FileSystem
Library           RPA.Archive
Library           RPA.Robocorp.Vault
Library           deleteFolder.py

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    #Run Keyword If NOT orders.csv exists
    #Ask user to input filepath -- must not commented, this will cause the bot to ask us two times! ;)
    Run Order
    Archiving folder
    Closing the browser

*** Variables ***
${DOWNLOAD_DIR}=    ${CURDIR}

*** Keywords ***
Open the robot order website
    ${URL}=    Get Secret    urls
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-
    Open Available Browser    ${URL}[order_page_url]
    Maximize Browser Window

Run Keyword If NOT orders.csv exists
    # Set Download Directory    ${DOWNLOAD_DIR}
    # Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Ask user to input filepath
    Add text input    filepath    label= insert here the file path
    ${response}=    Run dialog
    [Return]    ${response.filepath}

Click Order
    Click Button    id=order
    Wait Until Element Is Visible    id=receipt

Run Order
    ${response}=    Ask user to input filepath
    #${orders}=    Read table from CSV    orders.csv
    ${orders}=    Read table from CSV    ${response}
    #Log    ${orders}
    FOR    ${row}    IN    @{orders}
        #close annoying pop ups
        Click button When Visible    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
        #choose Head
        Select From List By Value    id=head    ${row}[Head]
        #choose body
        Click Button    id=id-body-${row}[Body]
        #choose legs
        Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
        #insert address
        Input Text    id=address    ${row}[Address]
        #click preview
        Click Button    id=preview
        Wait Until Keyword Succeeds    5 times    3 s    Click Order
        #Store the receipt as a PDF file
        ${GetText}=    Get Text    id=receipt
        Html To Pdf    ${GetText}    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].PDF
        #make screenshot
        Screenshot    id:robot-preview-image    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].PNG
        #create list
        ${files}=    Create List
        ...    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].PDF
        ...    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].PNG
        #Embed image to pdf
        Add Files To Pdf    ${files}    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].PDF
        #click button order another
        Click Button    id=order-another
        #removing file
        OperatingSystem.Remove File    ${DOWNLOAD_DIR}${/}Receipt${/}${row}[Order number].png
    END

Archiving folder
    Archive Folder With Zip    Receipt    receipt.zip
    Remove Folder    Receipt

Closing the browser
    Close Browser
