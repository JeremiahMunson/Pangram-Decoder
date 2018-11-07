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

# Each pangram and the code become Pangram objects allowing for easier access to the full and stripped version of a single pangram
class Pangram
    def initialize(line)
        @fullPangram = line
        @strippedPangram = Strip(line)
    end

    def fullPangram
        @fullPangram
    end
    def strippedPangram
        @strippedPangram
    end
end

######## Functions #########

# Strip(String): takes a String and strips away all the unwanted characters such as white space, commas, quotes, dashes, etc. but should just be white space
def Strip(line)
    #strippedLine: line with all the invalid characters stripped away, just the letters
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

# FindPangramsSameTotalLength(Pangram): takes a Pangram (the code) and finds the pangrams that match the same length (letters and white space)
# This is not necessary if there is only one pangram that matches the number of letters in the pangram 
def FindPangramsSameTotalLength(code)
    #allPossiblePangrams: array of classes that pangram have same number of letters as coded pangram
    allPossiblePangrams = $pangrams[code.strippedPangram.length]
    #sameLengthPangrams: array of classes that pangram full length is equal to full length of coded pangram
    sameLengthPangrams = Array.new()
    for pangramClasses in allPossiblePangrams
        sameLengthPangrams.push(pangramClasses) if (pangramClasses.fullPangram.length == code.fullPangram.length)
    end
    return sameLengthPangrams
end

# FindPangramsSameWords(Pangram, Array(Pangram)): Takes a Pangram (the code) and an array of Pangram objects and finds pangrams with same word sizes and order as the input pangram (code)
# This is for when there are multiple pangrams of same length finding the pangram with same word sizes must be the pangram. 
# If multiple or none can't decide which pangram it is
def FindPangramsSameWords(code, pangrams)
    #codeWords: array of arrays of chars where each array of chars is a word
    codeWords = SeperateWords(code.fullPangram)
    #sameLengthArray: array of arrays of arrays of chars where each array of chars is a word and each array of array of chars is a pangram
    sameLengthArray = Array.new()
    #sameLengthHash: hash where array of arrays of chars (a pangram) is key and the index number for sameLengthPangrams is value
    sameLengthHash = Hash.new()
    
    # Filling sameLengthArray and sameLengthHash with pangrams
    numberIndex = 0
    for phrase in pangrams
        pangramAsArray = SeperateWords(phrase.fullPangram)
        sameLengthArray.push(pangramAsArray)
        sameLengthHash[pangramAsArray] = numberIndex
        numberIndex+=1
    end

    #sameWordsPangrams: array of arrays of arrays of chars where this is last chance to figure it out (if .length != 1 we don't know)
    sameWordsPangrams = Array.new()

    # Filling sameWordsPangrams with pangrams that have same word sizes as code
    for pangramsRemaining in sameLengthArray
        allWordsSameSize = true
        for index in 0..(codeWords.length-1)
            if codeWords[index].length != pangramsRemaining[index].length
                allWordsSameSize = false
                break
            end
        end
        sameWordsPangrams.push(pangramsRemaining) if allWordsSameSize
    end

    # We know what the pangram is if sameWordsPangrams only has 1 pangram in it
    if sameWordsPangrams.length == 1
        # returned as a list because it needs to return a list if > 1 pangram and don't want to deal with returning two different tpes (Pangram vs Array(Pangram))
        return [pangrams[sameLengthHash[sameWordsPangrams[0]]]]
    # If there are multiple that match this we can check for repeating letters to compare so return all of them as a list
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

def SeperateWords(phrase)
    #word: array of characters where the array is a word
    word = Array.new() # looking back I don't know why I made this an array, not a string...but it works and I don't want to mess with it right now, maybe later
    #words: array of arrays of characters where array of characters is a word 
    words = Array.new()
    
    # Filling words
    phrase.each_char do |character|
        # false = white space, true = valid letter
        foundValid = false
        # if the character is valid then add it to the word
        for valid in $validCharacters
            # A space should seperate words
            if (character == valid)
                word.push(character)
                foundValid = true
                break
            end
        end
        # if the character wasn't a valid character it must be white space (or at least some kind of word-ending/seperating character) so the word stops there
        # added word.length > 0 to make sure it didn't do something weird in case there were back to back white spaces but this should never happen (but it doesn't hurt to be safe)
        if(!foundValid && word.length > 0)
            words.push(word)
            word = Array.new() # needs to start from being empty so that the previous word isn't carried over into the next word
        end
    end
    return words
end

# CheckRepeat(Pangram, Array(Pangram)): takes a Pangram (the code) and an Array of Pangrams (which should usually (or always) have one pangram in it, but useful to leave as array for adding more pangrams later)
# If a pangram has more than 26 letters there will be repeat letters so the correct pangram should have the same repeated characters at the same locations in the pangram
# This checks the repeated character locations of the predicted pangram(s) against the repeated character locations in the code to ensure proper pangram is found
# If 1 pangram matches that pangram must be the pangram used and returns that pangram, otherwise the program can't tell what pangram was used and returns nil 
def CheckRepeat(code, pangrams)
    #codeRepeats: Array of arrays where arrays are locations of repeated characters for the code
    codeRepeats = Repeats(code)

    #possiblePangrams: Array of pangrams that have the same locations of repeated characters
    possiblePangrams = Array.new()

    for pangram in pangrams
        #pangramRepeats: Array of arrays where arrays are locations of repeated characters for the pangram
        pangramRepeats = Repeats(pangram)

        for index in (0..codeRepeats.length - 1)
            differentRepeats = true
            for jindex in 0..(pangramRepeats.length - 1) # like for(int i...) {for(int j...){}} in C/C++
                differentRepeats = false if (codeRepeats[index] == pangramRepeats[jindex])
            end
            break if differentRepeats # differentRepeats is then 'true' when it goes to checking if the pangram should be added to possiblePangrams
        end
        # if the all the repeats are good differentRepeats will be false. if any repeats don't match up the loop above was broken and it's true
        possiblePangrams.push(pangram) if(!differentRepeats)
    end
    # If 1 pangram matches that pangram must be the pangram used and returns that pangram, otherwise the program can't tell what pangram was used and returns nil 
    (possiblePangrams.length == 1) ? (return possiblePangrams[0]) : (return nil)
end

# Repeats (Pangram): Finds the repeated character locations for the input Pangram 
# returns an Array of arrays where the arrays are the locations of characters that appear more than once in the phrase
# ex: str = "chopping wood" - repeats : Hash[o] = [2,10,11]; Hash[p] = [3,4]... returns [[2,10,11],[3,4]]
def Repeats(phrase)
    # phraseLetters: hash table where a-z are the keys and the locations of the characters as 1D Arrays are the values
    phraseLetters = Hash.new()
    for index in 0..(phrase.strippedPangram.length - 1)
        character = phrase.strippedPangram[index]
        phraseLetters.has_key?(character) ? phraseLetters[character].push(index) : phraseLetters[character] = [index]
    end

    # phraseRepeats: Array of arrays where the arrays are the locations of characters that appear more than once in the phrase
    phraseRepeats = Array.new()
    for letters, placement in phraseLetters
        # If it appears only once it doesn't matter, this is checking for repeated values
        if placement.length > 1
            phraseRepeats.push(placement)
        elsif placement.length < 1
            puts "NOT A PANGRAM! PANGRAMS USE ALL 26 LETTERS IN THE ALPHABET AND THIS DOESN'T USE ALL OF THEM!"
        end
    end
    return phraseRepeats
end

# SolveCode(Pangram, Pangram): takes a Pangram (the code) and a Pangram (the pangram used for the code)
# It "solves" the code by filling in $codeToEnglish and $englishToCode
# returns nothing, just makes changes to global variables ^^
def SolveCode(code, pangram)
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

# PrintCodeToEnglish(): Prints code to english comparison
def PrintCodeToEnglish()
    puts "Code: English"
    for keys,vals in $codeToEnglish
        break if(vals == nil)
        comparison = keys + ": " + vals
        puts comparison
    end
end

# PrintEnglishToCode(): Prints english to code comparison
def PrintEnglishToCode()
    puts "English: Code"
    for valid in $validCharacters
        comparison = valid + ": " + $englishToCode[valid]
        puts comparison
    end
end

## May not work after changes
def TestPangrams(list)
    pangramNumber = 1
    for listedPangram in list
        testPangram = Pangram.new(listedPangram)
        strippedListed = testPangram.strippedPangram
        lengthCode = strippedListed.length

        # If the length of the pangram doesn't match the length of any stored pangram it beat the program
        if(!$pangrams.key?(lengthCode))
            puts "The input does not match any stored pangram!"
        elsif($pangrams[lengthCode].length == 1)
            puts pangramNumber.to_s + ":Success" #$pangrams[lengthCode][0].fullPangram
        else
            ## TODO: A LOT HAS CHANGED SINCE I MADE THIS...WOW
            usedPangram = findPangram(listedPangram, strippedListed)
            if (usedPangram == nil)
                puts "Repeat char size, total size, and individual word sizes!"
            else
                puts pangramNumber.to_s + ":Success" #usedPangram.fullPangram
            end
        end
        pangramNumber+=1
    end
end

######################### END OF FUNCTIONS ##################################

################### Loading pangrams and making pangrams into pangram objects w/ stripped pangrams###################
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line.chomp)
end
file.close

for line in list
    newLine = Strip(line)
    # This is an if statement, if key in use append, otherwise make new key/value
    $pangrams.key?(newLine.length) ? $pangrams[newLine.length].push(Pangram.new(line)) : $pangrams[newLine.length] = [Pangram.new(line)] 
end

###################### Getting the user input code ##############################
puts "Please input coded pangram (do not include any hyphens, commas, quotes, periods, etc. only the 'letters' and spaces):"

while true
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

    break if(code.strippedPangram.length >= 26)
    puts "Not all letters are used, please input a pangram (a phrase that uses all 26 letters in the english alphabet:"
end

puts "Would you like to compare the coded with english by English:Code (E) or Code:English (C):"
while true
    comparisonVersion = gets.chomp
    comparisonVersion.upcase!
    break if(comparisonVersion == 'E' || comparisonVersion == 'C')
    puts "Invalid options...please input an E for English:Code or C for Code:English"
end

######################################## CHECKING INPUT AGAINST PANGRAMS ####################################################

##usedPangrams: the pangrams that the program thinks were used that the program then checks to make sure repeated letters/symbols are correct
#   it is very unlikely that there would be more than 1 pangram in this but just in case this is a good way to try and figure it out
#   If usedPangrams = nil then the code has already beaten the program
usedPangrams = nil

###### If the length of the pangram doesn't match the length of any stored pangram it beat the program
if(!$pangrams.key?(code.strippedPangram.length))
    puts "The number of characters in the input does not match any stored pangram!"

###### If the character length of the coded pangram matches only one stored pangram it must be that pangram
elsif($pangrams[code.strippedPangram.length].length == 1)
    usedPangrams = [$pangrams[code.strippedPangram.length][0]]

###### Otherwise considering pangrams of the same character length...
else
    sameLengthPangrams = FindPangramsSameTotalLength(code)
    
    ###### If the total length of the coded pangram matches only one stored pangram it must be that pangram 
    if(sameLengthPangrams.length == 1)
        usedPangrams = sameLengthPangrams
    
    ###### If the total length of the coded pangram doesn't match any pangrams it beat the program
    elsif(sameLengthPangrams.length == 0)
        puts "The full length of the input does not match any stored pangram!"
    
    ###### Otherwise considering only pangrams of the same character length and total length...
    else
        usedPangrams = FindPangramsSameWords(code, sameLengthPangrams)

        ###### If there are no saved pangrams that match the word lengths it beat the program
        if (usedPangrams == nil)
            puts "The word sizes and order for the input does not match any stored pangram!"
            # No if/else for if there was a pangram found because either way it'll go into the CheckRepeat section right after this
        end
    end
end

if(usedPangrams!=nil)
    # No need to check repeat letters if there are no repeated letters
    if(code.strippedPangram.length != 26)
        foundPangram = CheckRepeat(code, usedPangrams)

    # If only 1 believed pangram it must be that one (as far as the program can tell)
    elsif(usedPangrams.length == 1)
        foundPangram = usedPangrams[0]

    # If more than (or less than somehow) possible pangrams the program cannot determine which pangram was used
    else
        foundPangram = nil
    end

    if (foundPangram != nil)
        puts "Pangram is: ", foundPangram.fullPangram
        SolveCode(code.strippedPangram, foundPangram.strippedPangram)
        comparisonVersion == 'C' ? PrintCodeToEnglish() : PrintEnglishToCode()
    else
        puts "Cannot confidently determine the pangram."
    end
end

#TestPangrams(list)