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

# This is for when there are multiple pangrams of same length finding which one this is
def findPangram(code, stripped)
    #allPossiblePangrams: array of classes that pangram have same number of letters as coded pangram
    allPossiblePangrams = $pangrams[stripped.length]
    #sameLengthPangrams: array of classes that pangram full length is equal to full length of coded pangram
    sameLengthPangrams = Array.new()
    for pangramClasses in allPossiblePangrams
        sameLengthPangrams.push(pangramClasses) if (pangramClasses.fullPangram.length == code.length)
    end

    # If only 1 pangram that has same number of letters AND is the same length with spaces it must be that pangram
    # If there are no pangrams that have the same number of letters AND is the same length with spaces then the program can't figure out what pangram it is
    if sameLengthPangrams.length == 1
        return sameLengthPangrams[0]
    elsif sameLengthPangrams.length == 0
        return nil

    # This else is for when there are multiple pangrams of same length both stripped and full
    # It checks the size of the words of the pangrams and the coded pangram and compares them
    # The pangram with same word sizes must be the pangram. If multiple or none can't decide which pangram it is
    else
        #codeWords: array of arrays of chars where each array of chars is a word
        codeWords = seperateWords(code)
        #sameLengthArray: array of arrays of arrays of chars where each array of chars is a word and each array of array of chars is a pangram
        sameLengthArray = Array.new()
        #sameLengthHash: hash where array of arrays of chars (pangram) is key and the index number for sameLengthPangrams is value
        sameLengthHash = Hash.new()
        numberIndex = 0
        # Filling sameLengthArray and sameLengthHash with pangrams
        for phrase in sameLengthPangrams
            pangramAsArray = seperateWords(phrase.fullPangram)
            sameLengthArray.push(pangramAsArray)
            sameLengthHash[pangramAsArray] = numberIndex
            numberIndex+=1
        end

        #lastChancePangrams: array of arrays of arrays of chars where this is last chance to figure it out (if .length != 1 we don't know)
        lastChancePangrams = Array.new()
        # Filling lastChancePangrams with pangrams that have same word sizes as code
        for pangramsRemaining in sameLengthArray
            allWordsSameSize = true
            # don't need to check last word because if all words leading up to the last word match AND stripped length matches AND full length matches the last word must match
            for index in 0..(codeWords.length-1)
                if codeWords[index].length != pangramsRemaining[index].length
                    allWordsSameSize = false
                    break
                end
            end
            lastChancePangrams.push(pangramsRemaining) if allWordsSameSize
        end

        # We know what the pangram is if lastChancePangrams has .length == 1, otherwise we don't know
        if lastChancePangrams.length == 1
            foundPangram = sameLengthPangrams[sameLengthHash[lastChancePangrams[0]]]
            return foundPangram
        else
            return nil
        end
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
def solveCode(pangram, code)
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

##### Program #####

# Loading pangrams and making pangrams into pangram objects w/ stripped pangrams
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

=begin
puts "Would you like to test all pangrams to ensure they all work? (Y/N)"
start = gets.chomp
start.capitalize!

if (start == 'Y')
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
=end

# Getting the user input code
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

# If the length of the pangram doesn't match the length of any stored pangram it beat the program
if(!$pangrams.key?(code.strippedPangram.length))
    puts "The input does not match any stored pangram!"
elsif($pangrams[code.strippedPangram.length].length == 1)
    puts "Pangram is: ", $pangrams[code.strippedPangram.length][0].fullPangram
    solveCode($pangrams[code.strippedPangram.length][0].strippedPangram, code.strippedPangram)
    printCodeToEnglish()
else
    ## Making sure solveCode works
    usedPangram = findPangram(codedPangram, code.strippedPangram)
    if (usedPangram == nil)
        puts "The input does not match any stored pangram!"
    else
        puts "Pangram is: ", usedPangram.fullPangram
        solveCode(usedPangram.strippedPangram, code.strippedPangram)
        printCodeToEnglish()
    end
end