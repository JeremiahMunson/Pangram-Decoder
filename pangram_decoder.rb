# Reading in the list of pangrams stored in pangrams.txt
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line)
end
file.close

# Want pangrams to be stored in this hash table where the number of characters is the key
# The value is an array of pangrams with the same length
pangrams = Hash.new()

# This next part strips away all the unwanted characters (white space, commas, quotes, dashes, etc.)
validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
for line in list
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
    # This is an if statement, if key in use append, otherwise make new key/value
    pangrams.key?(numberChars) ? pangrams[numberChars].push(newLine) : pangrams[numberChars] = [newLine] 
end

