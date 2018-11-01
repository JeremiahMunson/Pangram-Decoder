# These global variables are the keys/values for the code
# The key is the code and value is english for codeToEnglish
# Vice Versa for englishToCode
$codeToEnglish = Hash.new()
$englishToCode = Hash.new()

# Want pangrams to be stored in this hash table where the number of characters is the key
# The value is an array of pangrams with the same length
$pangrams = Hash.new()

class Pangram
    def initialize(line)
        @fullPangram = line
        @size, @strippedPangram = strip(line)
    end

    def fullPangram
        @fullPangram
    end
    def strippedPangram
        @strippedPangram
    end
    def size
        @size
    end
end

######## Functions #########

# This next part strips away all the unwanted characters (white space, commas, quotes, dashes, etc.)
def strip(line)
    validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
    newLine = ""
    numberChars = 0
    line.each_char do |character|
        for valid in validCharacters
            if (character == valid) 
                newLine+=character
                numberChars+=1
                break
            end
        end
    end
    return numberChars, newLine
end

# This is for when there are multiple pangrams of same length finding which one this is
def findPangram(code, stripped)
    allPossiblePangrams = $pangrams[stripped.length]
    sameNumberSpacePangrams = []
    for pangramClasses in allPossiblePangrams
        sameNumberSpacePangrams.push(pangramClasses) if (pangramClasses.fullPangram.length == code.length)
        puts pangramClasses.fullPangram.size
    end
    if sameNumberSpacePangrams.length == 1
        return sameNumberSpacePangrams[0]
    elsif sameNumberSpacePangrams.length == 0
        return nil
    else
        #codeWords: array of words where each 
        codeWords = seperateWords(code)
        print codeWords
        remainingPangramWords = Array.new
        remainingPangramNumber = Hash.new
        numberIndex = 0
        for phrase in sameNumberSpacePangrams
            remainingPangramWords.push(seperateWords(phrase.fullPangram))
            remainingPangramNumber[seperateWords(phrase.fullPangram)] = numberIndex
            numberIndex+=1
        end
        lastChancePangrams = []
        for pangramsRemaining in remainingPangramWords
            allWordsSameSize = true
            for index in 0..(codeWords.length-1)
                if codeWords[index].length != pangramsRemaining[index].length
                    allWordsSameSize = false
                    break
                end
            end
            lastChancePangrams.push(pangramsRemaining) if allWordsSameSize
        end
        if lastChancePangrams.length == 1
            foundPangram = sameNumberSpacePangrams[remainingPangramNumber[lastChancePangrams[0]]]
            return foundPangram
        else
            return nil
        end
    end
end

def seperateWords(phrase)
    validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
    words = []
    word = []
    phrase.each_char do |character|
        found = false
        for valid in validCharacters
            if (character == valid)
                word.push(character)
                found = true
                break
            end
        end
        if(!found && word.length > 0)
            words.push(word)
            word = []
        end
    end
    return words
end

# This uses the codeToEnglish and englishToCode hash tables into a key for the code
def solveCode(pangram, code)
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

##### Program #####

# Reading in the list of pangrams stored in pangrams.txt
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line.chomp)
end
file.close

for line in list
    numberChars, newLine = strip(line)
    # This is an if statement, if key in use append, otherwise make new key/value
    $pangrams.key?(numberChars) ? $pangrams[numberChars].push(Pangram.new(line)) : $pangrams[numberChars] = [Pangram.new(line)] 
end

# Getting the user input code
codedPangram = gets.chomp
lengthCode, strippedCode = strip(codedPangram)

# If the length of the pangram doesn't match the length of any stored pangram it beat the program
if(!$pangrams.key?(lengthCode))
    puts "The input does not match any stored pangram!"
elsif($pangrams[lengthCode].length == 1)
    puts "Pangram is: ", $pangrams[lengthCode][0].fullPangram
    solveCode($pangrams[lengthCode][0].strippedPangram, strippedCode)
    printCodeToEnglish()
else
    ## Making sure solveCode works
    usedPangram = findPangram(codedPangram, strippedCode)
    if (usedPangram == nil)
        puts "The input does not match any stored pangram!"
    else
        puts "Pangram is: ", usedPangram.fullPangram
        solveCode(usedPangram.strippedPangram, strippedCode)
        printCodeToEnglish()
    end
end