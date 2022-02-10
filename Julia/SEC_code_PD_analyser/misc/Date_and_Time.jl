using Dates

#Takes the filename and creates a string starting with Date and time
function DateAndTime(fileName)
    hour = string(Dates.hour(now()))
    minute = string(Dates.minute(now()))
    date =  string(Dates.today())
    FinalFileName=("$date $hour-$minute $fileName")
    return FinalFileName
end