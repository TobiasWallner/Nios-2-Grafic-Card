#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cinttypes>
#include <cmath>
#include <bitset>

void generate(const uint32_t fix, std::ofstream& sourceFile, std::ofstream& resultFile){
	const double fix_d = static_cast<double>(fix) / 65536.;
	const double expected_result = 1./sqrt(fix_d);
	const uint32_t result = static_cast<int32_t>(expected_result * 65536.);
	
	const auto fix_bits = std::bitset<32>(fix);
	const auto result_bits = std::bitset<32>(result);
	
	const auto fix_bits_high = std::bitset<16>((fix >> 16) & 0xFFFF);
	const auto fix_bits_low = std::bitset<16>(fix & 0xFFFF);
	const auto result_bits_high = std::bitset<16>((result >> 16) & 0xFFFF);
	const auto result_bits_low = std::bitset<16>(result & 0xFFFF);
	
	sourceFile << fix_bits << "\n";
	resultFile << result_bits << "\n";
	
	//std::cout << "1/sqrt(" << fix_d << ") = " << expected_result << std::endl;
	//std::cout << "\t1/sqrt(" << fix_bits_high << "." << fix_bits_low << ") = " << result_bits_high << "." << result_bits_low << std::endl;
}

int main(){
	const uint32_t seed = 21;
	std::srand(seed);
	
	std::ofstream tbSourceFile("tb_source.txt");
	std::ofstream tbResultFile("tb_expected.txt");
	
	for(uint32_t i = 0; i != 32; ++i){
		generate(1 << i, tbSourceFile, tbResultFile);
	}
	
	uint32_t mask;
	while(mask != 0xFFFFFFFF){
		mask = (mask << 4) | 0xF;
		for(uint32_t i = 0; i < std::log2(mask)+1; ++i){
			const int32_t random = std::rand() & mask;
			generate(random, tbSourceFile, tbResultFile);
		}
	}
	return 0;
}
