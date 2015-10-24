#include <opencv2/opencv.hpp>

int main() {
	cv::Mat image = cv::imread("Lenna.jpg");
	cv::namedWindow("input");
	cv::imshow("input", image);
	cv::waitKey();
	cv::imwrite("output.jpg", image);
}