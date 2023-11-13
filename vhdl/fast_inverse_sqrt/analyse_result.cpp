#include <iostream>
#include <fstream>
#include <vector>
#include <cinttypes>
#include <cmath>
#include <algorithm>
#include <functional>

#include <blaze/Blaze.h>

static uint32_t bitstring_to_int32(const char* buffer, const int32_t count){
	const char * const buffer_end = buffer + count;
	uint32_t result = 0;
	for(const char* itr = buffer; itr != buffer_end && *itr != '\0'; ++itr){
		result = (result << 1) | (*itr == '1');
	}
	return result;
}

static uint32_t read_binary_test_vector(std::ifstream& ifstream){
	char buffer[64];
	ifstream.getline(buffer, sizeof(buffer));
	const uint32_t number = bitstring_to_int32(buffer, sizeof(buffer));
	return number;
}

static double fix16_to_double(uint32_t fix16){return static_cast<double>(fix16) / (1 << 16);}

blaze::DynamicVector<double> parse_file(const char* filename){
	std::ifstream file(filename);
	blaze::DynamicVector<double> result;
	result.reserve(1024);
	
	uint32_t count = 0;	
	while(!file.eof()){
		const uint32_t number = read_binary_test_vector(file);
		const double number_d = fix16_to_double(number);
		result.resize(count+1);
		result[count] = number_d; // appends number_d at count position
		++count;
	}
	result.resize(count-3);
	
	result.shrinkToFit();
	return result;
}

int main(){
	std::ofstream file("analyse.txt");

	blaze::DynamicVector<double> expected = parse_file("tb_expected.txt");
	blaze::DynamicVector<double> result = parse_file("tb_result.txt");	
	blaze::DynamicVector<double> error = (expected - result) / expected;
	
	const double mean = blaze::mean(error);
	std::cout << "mean-error: " << mean * 100 << "%" << std::endl;
	file << "mean-error: " << mean * 100 << "%" << std::endl;
	
	const double stddev = blaze::stddev(error) ;
	std::cout << "standard_deviation: " << stddev * 100 << "%" << std::endl;
	file << "standard_deviation: " << stddev * 100 << "%" << std::endl;
}
