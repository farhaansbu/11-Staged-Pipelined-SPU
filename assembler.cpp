#include <iostream>
#include <algorithm>
#include <fstream>
#include <string>
#include <bitset>
#include <cctype>
#include <unordered_map>
#include <sstream>
#include <vector>

// Helper function to convert integer to binary
std::string intToBinary(const std::string& intStr, int numBits) {
    // Convert string to int
    int num;
    try {
        num = std::stoi(intStr);
    }
    catch (const std::exception& e) {
        throw std::invalid_argument("Invalid integer string");
    }

    // Check if numBits is valid
    if (numBits <= 0 || numBits > 32) {
        throw std::invalid_argument("Number of bits must be between 1 and 32");
    }

    // Check if value fits in the given number of bits (signed range)
    int minVal = -(1 << (numBits - 1));
    int maxVal = (1 << (numBits - 1)) - 1;
    if (num < minVal || num > maxVal) {
        throw std::invalid_argument("Immediate value " + intStr +
            " out of range for " + std::to_string(numBits) + " bits");
    }

    // Cast to unsigned so bitset handles two's complement correctly
    std::bitset<32> bits(static_cast<unsigned int>(num));
    return bits.to_string().substr(32 - numBits);
}


// Strips the 'r' or $ prefix from a register and converts to binary
std::string regToBinary(const std::string& reg, int numBits) {
    std::string numPart = reg;
    if (!numPart.empty() && (std::tolower(numPart[0]) == 'r' || numPart[0] =='$'))
        numPart = numPart.substr(1);
    return intToBinary(numPart, numBits);
}

// Tokenize operands from the remainder of the instruction string
std::vector<std::string> parseOperands(const std::string& instruction, int startPos) {
    std::vector<std::string> operands;
    std::string segment = instruction.substr(startPos);
    std::stringstream ss(segment);
    std::string token;

    while (std::getline(ss, token, ',')) {
        // Trim whitespace from each token
        token.erase(0, token.find_first_not_of(" \t"));
        token.erase(token.find_last_not_of(" \t") + 1);
        if (!token.empty())
            operands.push_back(token);
    }
    return operands;
}


enum class InstrType { RR, RI7, RI10, RI16, RRR, RI18, NOP };

struct InstrInfo {
    std::string opcode;
    InstrType type;
};

int main(void)
{
    std::ifstream inpf{ "assembly_instructions.txt" };
    std::ofstream outpf{ "instructions1.txt" };

/*      Instruction Types   */  
    std::unordered_map<std::string, InstrInfo> opcodeMap = {
    /*Testing Stuff*/
    //{"slhi", {"110000001", InstrType::RI16}}, //9 bit opcode (good)
    //{"au",   {"11000000", InstrType::RI10}},  //8 bit opcode (good)
    //{"smaddl", {"1000",    InstrType::RRR}}, //4 bit opcode (good)
    //{"a", {"11110000111",    InstrType::RR }},   //11 bit opcode (good)
    //{"subi",{"10000000000",    InstrType::RI7}},  //11 bit opcode (good)
    //{"ilw", {"1000011",    InstrType::RI18}}  //7 bit opcode (good)
    //nop type is also tested 
    
    //RRR instruction type (4)
    {"mpya", {"1100", InstrType::RRR}},
    {"fma", {"1110", InstrType::RRR}},
    {"fnms", {"1101", InstrType::RRR}},
    {"fms", {"1111", InstrType::RRR}},

    //RI18 Type (1)
    {"ila", {"0100001", InstrType::RI18}},
 
    //RI10 Type (20)
    {"ai",    {"00011100", InstrType::RI10}},
    {"ahi",   {"00011101", InstrType::RI10}},
    {"sfi",   {"00001100", InstrType::RI10}},
    {"sfhi",  {"00001101", InstrType::RI10}},
    {"andi",  {"00010100", InstrType::RI10}},
    {"andhi", {"00010101", InstrType::RI10}},
    {"ori",   {"00000100", InstrType::RI10}},
    {"orhi",  {"00000101", InstrType::RI10}},
    {"xori",  {"01000100", InstrType::RI10}},
    {"xorhi", {"01000101", InstrType::RI10}},
    {"ceqi",  {"01111100", InstrType::RI10}},
    {"ceqhi", {"01111101", InstrType::RI10}},
    {"cgti",  {"01001100", InstrType::RI10}},
    {"cgthi", {"01001101", InstrType::RI10}},
    {"clgti", {"01011100", InstrType::RI10}},
    {"clgthi",{"01011101", InstrType::RI10}},
    {"mpyi",  {"01110100", InstrType::RI10}},
    {"mpyui", {"01110101", InstrType::RI10}},
    {"lqd",   {"00110100", InstrType::RI10}},
    {"stqd",  {"00100100", InstrType::RI10}},

    //R16 type (14)
    {"il",    {"010000001", InstrType::RI16}},
    {"ilh",   {"010000011", InstrType::RI16}},
    {"ilhu",  {"010000010", InstrType::RI16}},
    {"iohl",  {"011000001", InstrType::RI16}},
    {"lqa",   {"001100001", InstrType::RI16}},
    {"stqa",  {"001000001", InstrType::RI16}},
    {"br",    {"001100100", InstrType::RI16}},
    {"bra",   {"001100000", InstrType::RI16}},
    {"brsl",  {"001100110", InstrType::RI16}},
    {"brasl", {"001100010", InstrType::RI16}},
    {"brz",   {"001000000", InstrType::RI16}},
    {"brhz",  {"001000100", InstrType::RI16}},
    {"brnz",  {"001000010", InstrType::RI16}},
    {"brhnz", {"001000110", InstrType::RI16}},

    //RI7 type (6 total)
    { "shli",   {"00001111011", InstrType::RI7}},
    {"shlhi",   {"00001111111", InstrType::RI7}},
    {"roti",    {"00001111000", InstrType::RI7}},
    {"rothi",   {"00001111100", InstrType::RI7}},
    {"shlqbyi", {"00111111111", InstrType::RI7}},
    {"rotqbyi", {"00111111100", InstrType::RI7}},
    
    //RR type (50 total)
    {"a",       {"00011000000", InstrType::RR}},
    {"ah",      {"00011001000", InstrType::RR}},
    {"sf",      {"00001000000", InstrType::RR}},
    {"sfh",     {"00001001000", InstrType::RR}},
    {"cg",      {"00011000010", InstrType::RR}},
    {"bg",      {"00001000010", InstrType::RR}},
    {"and",     {"00011000001", InstrType::RR}},
    {"or",      {"00001000001", InstrType::RR}},
    {"xor",     {"01001000001", InstrType::RR}},
    {"nand",    {"00011001001", InstrType::RR}},
    {"nor",     {"00001001001", InstrType::RR}},
    {"ceq",     {"01111000000", InstrType::RR}},
    {"ceqh",    {"01111001000", InstrType::RR}},
    {"cgt",     {"01001000000", InstrType::RR}},
    {"cgth",    {"01001001000", InstrType::RR}},
    {"clgt",    {"01011000000", InstrType::RR}},
    {"clgth",   {"01011001000", InstrType::RR}},
    {"shl",     {"00001011011", InstrType::RR}},
    {"shlh",    {"00001011111", InstrType::RR}},
    {"rot",     {"00001011000", InstrType::RR}},
    {"roth",    {"00001011100", InstrType::RR}},
    {"rotm",    {"00001011001", InstrType::RR}},
    {"rothm",   {"00001011101", InstrType::RR}},
    {"rotma",   {"00001011010", InstrType::RR}},
    {"rotmah",  {"00001011110", InstrType::RR}},
    {"mpy",     {"01111000100", InstrType::RR}},
    {"mpyu",    {"01111001100", InstrType::RR}},
    {"fa",      {"01011000100", InstrType::RR}},
    {"fs",      {"01011000101", InstrType::RR}},
    {"fm",      {"01011000110", InstrType::RR}},
    {"fceq",    {"01111000010", InstrType::RR}},
    {"fcmeq",   {"01111001010", InstrType::RR}},
    {"fcgt",    {"01011000010", InstrType::RR}},
    {"fcmgt",   {"01011001010", InstrType::RR}},
    {"avgb",    {"00011010011", InstrType::RR}},
    {"sumb",    {"01001010011", InstrType::RR}},
    {"absdb",   {"00001010011", InstrType::RR}},
    {"shlqby",  {"00111011111", InstrType::RR}},
    {"shlqbi",  {"00111011011", InstrType::RR}},
    {"rotqby",  {"00111011100", InstrType::RR}},
    {"rotqbi",  {"00111011000", InstrType::RR}},
    {"rotqmby", {"00111011101", InstrType::RR}},
    {"lqx",     {"00111000100", InstrType::RR}},
    {"stqx",    {"01001000100", InstrType::RR}},
    {"cntb",    {"01010110100", InstrType::RR}},
    {"clz",     {"01010100101", InstrType::RR}},
    {"fsmh",    {"00110110101", InstrType::RR}},
    {"fsm",     {"00110110100", InstrType::RR}},

    /* Parse these as RR but treat them as RRR later */
    {"addx",    {"0110", InstrType::RR}},
    {"sfx",     {"0110", InstrType::RR}},

    //branch instructions (6)
    // RR type � branch indirect (RB unused, 2 operand)
    { "bisl",  {"00110101001", InstrType::RR} },
    { "bi",    {"00110101000", InstrType::RR} },
    { "biz",   {"00100101000", InstrType::RR} },
    { "bihz",  {"00100101010", InstrType::RR} },
    { "binz",  {"00100101001", InstrType::RR} },
    { "bihnz", {"00100101011", InstrType::RR} },

    // NOP type � no operands (2)
    { "lnop",  {"00000000001", InstrType::NOP} },
    { "nop",   {"01000000001", InstrType::NOP} },
    { "stop",   {"00000000000", InstrType::NOP} }

    };

    if (!inpf)
    {
        // Print an error and exit
        std::cerr << "Uh oh, assembly_instructions.txt could not be opened for reading!\n";
        return 1;
    }

    if (!outpf)
    {
        // Print an error and exit
        std::cerr << "Uh oh, instructions.txt could not be opened for writing!\n";
        return 1;
    }

    // -------------------------------------------------------
    // Pass 1: collect labels and store all lines
    // -------------------------------------------------------
    std::unordered_map<std::string, int> labelMap;
    std::vector<std::string> lines;
    int instrCount = 0;
    std::string line;

    while (std::getline(inpf, line))
    {
        // Trim leading whitespace
        line.erase(0, line.find_first_not_of(" \t"));
        if (line.empty()) continue;

        lines.push_back(line);

        if (line.back() == ':')
        {
            std::string label = line.substr(0, line.size() - 1);
            labelMap[label] = instrCount;
            std::cout << "Found label: " << label << " at address " << instrCount << '\n';
        }
        else
        {
            instrCount++;
        }
    }


    std::string instruction;
    std::string output;
    std::string operation;

    // -------------------------------------------------------
    // Pass 2: encode instructions
    // -------------------------------------------------------
    instrCount = 0;

    for (const std::string& instruction : lines)
    {
        if (instruction.back() == ':') continue;

        output = "";
        operation = "";
        int i = 0;

        // Read mnemonic
        while (i < (int)instruction.size() && instruction[i] != ' ')
            operation += instruction[i++];

        // Convert mnemonic to lowercase
        std::transform(operation.begin(), operation.end(), operation.begin(),
            [](unsigned char c) { return std::tolower(c); });

        std::cout << "operation: " << operation << '\n';

        // Look up in unified map
        auto it = opcodeMap.find(operation);
        if (it == opcodeMap.end())
        {
            std::cerr << "Unknown operation: " << operation << '\n';
            continue;
        }

        const std::string& opcode = it->second.opcode;
        InstrType type = it->second.type;

        // Parse operands from after the mnemonic
        std::vector<std::string> operands = parseOperands(instruction, i);

        // Resolves a label to its address, or falls back to a plain immediate
        auto resolveOperand = [&](const std::string& operand, int numBits, bool isRelative) -> std::string
            {
                if (labelMap.count(operand))
                {
                    if (isRelative)
                    {
                        int offset = labelMap[operand] - instrCount;
                        //std::cout << "offset = " << labelMap[operand] << " - " << instrCount << " = " << offset << '\n';

                        return intToBinary(std::to_string(offset), numBits);
                    }
                    else
                    {
                        return intToBinary(std::to_string(labelMap[operand]), numBits);
                    }
                }
                return intToBinary(operand, numBits);
            };


        try
        {
            switch (type)
            {
                // OP(11) | RB(7) | RA(7) | RT(7)
            case InstrType::RR:
            {
                //// Expects: RT, RA, RB
                //std::string rt = regToBinary(operands[0], 7);
                //std::string ra = regToBinary(operands[1], 7);
                ////std::string rb = regToBinary(operands[2], 7);
                ////handles RR instruction with no RB
                //std::string rb = (operands.size() == 3) ? regToBinary(operands[2], 7) : "0000000";
                //output = opcode + rb + ra + rt;
                //break;
                std::string rt = "0000000";
                std::string ra = "0000000";
                std::string rb = "0000000";

                if (operands.size() == 3)
                {
                    // Standard RR: RT, RA, RB
                    rt = regToBinary(operands[0], 7);
                    ra = regToBinary(operands[1], 7);
                    rb = regToBinary(operands[2], 7);
                }
                else if (operands.size() == 2)
                {
                    // 2 operand RR: RT, RA (e.g. clz, fsm, bisl)
                    rt = regToBinary(operands[0], 7);
                    ra = regToBinary(operands[1], 7);
                }
                else if (operands.size() == 1)
                {
                    // 1 operand RR: RA only (e.g. bi)
                    ra = regToBinary(operands[0], 7);
                }

                output = opcode + rb + ra + rt;
                break;
            }
            // OP(11) | I7(7) | RA(7) | RT(7)
            case InstrType::RI7:
            {
                // Expects: RT, RA, I7
                std::string rt = regToBinary(operands[0], 7);
                std::string ra = regToBinary(operands[1], 7);
                std::string i7 = intToBinary(operands[2], 7);
                output = opcode + i7 + ra + rt;
                break;
            }
            // OP(4) | RT(7) | RB(7) | RA(7) | RC(7)
            case InstrType::RRR:
            {
                // Expects: RT, RA, RB, RC
                std::string rt = regToBinary(operands[0], 7);
                std::string ra = regToBinary(operands[1], 7);
                std::string rb = regToBinary(operands[2], 7);
                std::string rc = regToBinary(operands[3], 7);
                output = opcode + rt + rb + ra + rc;
                break;
            }
            // OP(7) | I18(18) | RT(7)
            case InstrType::RI18:
            {
                // Expects: RT, I18
                std::string rt = regToBinary(operands[0], 7);
                std::string i18 = intToBinary(operands[1], 18);
                output = opcode + i18 + rt;
                break;
            }
            // OP(8) | I10(10) | RA(7) | RT(7)
            case InstrType::RI10:
            {
                // Expects: RT, RA, I10
                std::string rt = regToBinary(operands[0], 7);
                std::string ra = regToBinary(operands[1], 7);
                std::string i10 = intToBinary(operands[2], 10);
                output = opcode + i10 + ra + rt;
                break;
            }
            // OP(9) | I16(16) | RT(7)
            case InstrType::RI16:
            {
                // Expects: RT, I16
                /*std::string rt = regToBinary(operands[0], 7);
                std::string i16 = intToBinary(operands[1], 16);
                output = opcode + i16 + rt;*/

                bool noDstReg = (operation == "br" || operation == "bra");
                bool isRelative = (operation == "br" || operation == "brsl" ||
                    operation == "brz" || operation == "brhz" ||
                    operation == "brnz" || operation == "brhnz");

                std::string rt = noDstReg ? "0000000" : regToBinary(operands[0], 7);

                std::string i16 = resolveOperand(operands.back(), 16, isRelative);
                std::cout << "rt  = " << rt << " (" << rt.size() << " bits)\n";
                std::cout << "i16 = " << i16 << " (" << i16.size() << " bits)\n";
                output = opcode + i16 + rt;
                break;
            }

            // All zeroes
            case InstrType::NOP:
            {
                output = opcode + std::string(32 - opcode.size(), '0');
                break;
            }

            }

            std::cout << "Binary: " << output << " (" << output.size() << " bits)\n";
            //std::cout << "Instruction Count: " << instrCount << std::endl;
            //std::cout << "output:       " << output << '\n';
            outpf << output << '\n';
        }
        catch (const std::exception& e)
        {
            std::cerr << "Error encoding '" << operation << "': " << e.what() << '\n';
        }

        instrCount++;
    }

    return 0;
}