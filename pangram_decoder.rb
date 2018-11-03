# These global variables are the keys/values for the code
# The key is the code and value is english for codeToEnglish
# Vice Versa for englishToCode
$codeToEnglish = Hash.new()
$englishToCode = Hash.new()

# Want pangrams to be stored in this hash table where the number of characters is the key
# The value is an array of pangrams with the same length
$pangrams = Hash.new()


# The only characters we care about are letters and numbers if the user wants to user numbers as part of the code
$validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

class Pangram
    def initialize(line)
        @fullPangram = line
        @strippedPangram = strip(line)
    end

    def fullPangram
        @fullPangram
    end
    def strippedPangram
        @strippedPangram
    end
end

######## Functions #########

# This next part strips away all the unwanted characters (white space, commas, quotes, dashes, etc.)
def strip(line)
    #strippedLine: line with all the invalid characters stripped away. Just letters and numbers
    strippedLine = String.new()
    line.each_char do |character|
        for valid in $validCharacters
            if (character == valid) 
                strippedLine+=character
                break
            end
        end
    end
    return strippedLine
end

def findPangramsSameTotalLength(code)
    #allPossiblePangrams: array of classes that pangram have same number of letters as coded pangram
    allPossiblePangrams = $pangrams[code.strippedPangram.length]
    #sameLengthPangrams: array of classes that pangram full length is equal to full length of coded pangram
    sameLengthPangrams = Array.new()
    for pangramClasses in allPossiblePangrams
        sameLengthPangrams.push(pangramClasses) if (pangramClasses.fullPangram.length == code.fullPangram.length)
    end
    return sameLengthPangrams
end

# This is for when there are multiple pangrams of same length finding which one this is
# It checks the size of the words of the pangrams and the coded pangram and compares them
# The pangram with same word sizes must be the pangram. If multiple or none can't decide which pangram it is
def findPangramSameWords(code, pangrams)
    #codeWords: array of arrays of chars where each array of chars is a word
    codeWords = seperateWords(code.fullPangram)
    #sameLengthArray: array of arrays of arrays of chars where each array of chars is a word and each array of array of chars is a pangram
    sameLengthArray = Array.new()
    #sameLengthHash: hash where array of arrays of chars (pangram) is key and the index number for sameLengthPangrams is value
    sameLengthHash = Hash.new()
    
    # Filling sameLengthArray and sameLengthHash with pangrams
    numberIndex = 0
    for phrase in pangrams
        pangramAsArray = seperateWords(phrase.fullPangram)
        sameLengthArray.push(pangramAsArray)
        sameLengthHash[pangramAsArray] = numberIndex
        numberIndex+=1
    end

    #sameWordsPangrams: array of arrays of arrays of chars where this is last chance to figure it out (if .length != 1 we don't know)
    sameWordsPangrams = Array.new()
    # Filling sameWordsPangrams with pangrams that have same word sizes as code
    for pangramsRemaining in sameLengthArray
        allWordsSameSize = true
        # don't need to check last word because if all words leading up to the last word match AND stripped length matches AND full length matches the last word must match
        for index in 0..(codeWords.length-1)
            if codeWords[index].length != pangramsRemaining[index].length
                allWordsSameSize = false
                break
            end
        end
        sameWordsPangrams.push(pangramsRemaining) if allWordsSameSize
    end

    # We know what the pangram is if sameWordsPangrams has .length == 1
    if sameWordsPangrams.length == 1
        returnValue = [pangrams[sameLengthHash[sameWordsPangrams[0]]]]
        return returnValue
    # If there are multiple that match this we can check for repeating letters to compare??
    elsif sameWordsPangrams.length > 1
        returnValue = Array.new()
        for index in 0..(sameWordsPangrams.length-1)
            returnValue.push(pangrams[sameLengthHash[sameWordsPangrams[index]]])
        end
        return returnValue
    # Otherwise we don't know
    else
        return nil
    end
end

def seperateWords(phrase)
    #word: array of characters where the array is a word
    word = Array.new()
    #words: array of arrays of characters where array of characters is a word 
    words = Array.new()
    # Filling words
    phrase.each_char do |character|
        found = false
        for valid in $validCharacters
            # A space or hyphen should seperate words
            if (character == valid)
                word.push(character)
                found = true
                break
            end
        end
        if(!found && word.length > 0)
            words.push(word)
            word = Array.new()
        end
    end
    return words
end

# This uses the codeToEnglish and englishToCode hash tables into a key for the code
def solveCode(code, pangram)
    # did 'index in 0..pangram.length' instead of 'something in pangram' because it needs to go through pangram and code together and index like this works for both
    for index in 0..pangram.length
        char = code[index]
        letter = pangram[index]
        if !$codeToEnglish.key?(char) 
            $codeToEnglish[char] = letter 
        end
        if !$englishToCode.key?(letter) 
            $englishToCode[letter] = char 
        end
    end
end

# Prints code to english comparison
def printCodeToEnglish()
    puts "Code: English"
    for keys,vals in $codeToEnglish
        break if(vals == nil)
        comparison = keys + ": " + vals
        puts comparison
    end
end

# Prints english to code comparison
def printEnglishToCode()
    puts "English: Code"
    for keys,vals in $englishToCode
        break if(vals == nil)
        comparison = keys + ": " + vals
        puts comparison
    end
end

## May not work after changes
def TestPangrams()
    pangramNumber = 1
    for codedPangram in list
        strippedCode = strip(codedPangram)

        # If the length of the pangram doesn't match the length of any stored pangram it beat the program
        if(!$pangrams.key?(lengthCode))
            puts "The input does not match any stored pangram!"
        elsif($pangrams[lengthCode].length == 1)
            puts pangramNumber.to_s + ":Success" #$pangrams[lengthCode][0].fullPangram
        else
            ## Making sure solveCode works
            usedPangram = findPangram(codedPangram, strippedCode)
            if (usedPangram == nil)
                puts "Repeat char size, total size, and individual word sizes!"
            else
                puts pangramNumber.to_s + ":Success" #usedPangram.fullPangram
            end
        end
        pangramNumber+=1
    end
end

def checkRepeat(code, pangrams)
    codeRepeats = Repeats(code)

    possiblePangrams = Array.new()

    for pangram in pangrams
        pangramRepeats = Repeats(pangram)

        for index in (0..codeRepeats.length - 1)
            differentRepeats = true
            for jindex in 0..(pangramRepeats.length - 1)
                differentRepeats = false if (codeRepeats[index] == pangramRepeats[jindex])
            end
            if differentRepeats
                break
                # differentRepeats is then 'true' when it goes to checking if the pangram should be added to possiblePangrams
            end
        end
        # if the all the repeats are good differentRepeats will be false. if any repeats don't match up the loop above was broken and it's true
        possiblePangrams.push(pangram) if(!differentRepeats)
    end
    (possiblePangrams.length > 0) ? (return pangrams[0]) : (return nil)
end

def Repeats(phrase)
    phraseLetters = Hash.new()
    #phrase.strippedPangram.each_char do |character|
    for index in 0..(phrase.strippedPangram.length - 1)
        character = phrase.strippedPangram[index]
        phraseLetters.has_key?(character) ? phraseLetters[character].push(index) : phraseLetters[character] = [index]
    end
    phraseRepeats = Array.new()
    for letters, placement in phraseLetters
        if placement.length > 1
            phraseRepeats.push(placement)
        elsif placement.length < 1
            puts "PROBLEM!"
        end
    end
    return phraseRepeats
end

############################################### Program ####################################################################

################### Loading pangrams and making pangrams into pangram objects w/ stripped pangrams###################
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line.chomp)
end
file.close

for line in list
    newLine = strip(line)
    # This is an if statement, if key in use append, otherwise make new key/value
    $pangrams.key?(newLine.length) ? $pangrams[newLine.length].push(Pangram.new(line)) : $pangrams[newLine.length] = [Pangram.new(line)] 
end

###################### Getting the user input code ##############################
puts "Please input coded pangram (do not include any hyphens, commas, quotes, periods, etc. only the 'letters' and spaces):"
codedPangram = gets.chomp

####################### CLEANING USER INPUT CODED PANGRAM ##################################
## Need to clean the input so that checking the full length against pangram full lengths is accurate
codedPangram = codedPangram.tr('\'', '')
codedPangram.downcase!
# Removing unwanted characters and replacing them with whitespace
for index in 0..(codedPangram.length - 1)
    invalid = true
    for valid in $validCharacters
        if valid == codedPangram[index]
            invalid = false
            break
        end
    end
    if invalid
        codedPangram[index] = " "
    end
end
# Removing extra whitespace at beginning an end
codedPangram.strip!
# Removing back to back whitespaces
for index in 0..(codedPangram.length-2)
    if ((codedPangram[index] == " " && codedPangram[index+1] == " " )|| (codedPangram[index] == " " && codedPangram[index-1] == " " ))
        codedPangram[index] = ''
    end
end

code = Pangram.new(codedPangram)

alreadyLost = false

##usedPangrams: the pangrams that the program thinks were used that the program then checks to make sure repeated letters/symbols are correct
#   it is very unlikely that there would be more than 1 pangram in this but just in case this is a good way to try and figure it out

###### If the length of the pangram doesn't match the length of any stored pangram it beat the program
if(!$pangrams.key?(code.strippedPangram.length))
    puts "The number of characters in the input does not match any stored pangram!"
    alreadyLost = true

###### If the character length of the coded pangram matches only one stored pangram it must be that pangram
elsif($pangrams[code.strippedPangram.length].length == 1)
    usedPangrams = [$pangrams[code.strippedPangram.length][0]]

###### Otherwise considering pangrams of the same character length...
else
    sameLengthPangrams = findPangramsSameTotalLength(code)
    
    ###### If the total length of the coded pangram matches only one stored pangram it must be that pangram 
    if(sameLengthPangrams.length == 1)
        usedPangrams = [sameLengthPangrams]
    
    ###### If the total length of the coded pangram doesn't match any pangrams it beat the program
    elsif(sameLengthPangrams.length == 0)
        puts "The full length of the input does not match any stored pangram!"
        alreadyLost = true
    
    ###### Otherwise considering only pangrams of the same character length and total length...
    else
        usedPangrams = findPangramSameWords(code, sameLengthPangrams)

        ###### If there are no saved pangrams that match the word lengths it beat the program
        if (usedPangrams == nil)
            puts "The word sizes and order for the input does not match any stored pangram!"
            alreadyLost = true
            # No if/else for if there was a pangram found because either way it'll go into the checkRepeat section right after this
        end
    end
end

if(!alreadyLost)
    # No need to check repeat letters if there are no repeated letters
    if(code.strippedPangram.length != 26)
        foundPangram = checkRepeat(code, usedPangrams)

    # If only 1 believed pangram it must be that one (as far as the program can tell)
    elsif(usedPangrams.length = 1)
        foundPangram = usedPangrams[0]

    # If more than (or less than somehow) possible pangrams the program cannot determine which pangram was used
    else
        foundPangram = nil
    end

    if (foundPangram != nil)
        puts "Pangram is: ", foundPangram.fullPangram
        solveCode(code.strippedPangram, foundPangram.strippedPangram)
        printCodeToEnglish
    else
        puts "Cannot confidently determine the pangram."
    end
end