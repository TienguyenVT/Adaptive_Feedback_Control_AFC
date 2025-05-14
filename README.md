# Acoustic Feedback Cancellation using Prediction Error Method (PEM-AFC)

## 1 Keep it Simple

Acoustic Feedback Cancellation using Prediction Error Method

This project focuses on solving the acoustic feedback problem (howling or whistling sounds) commonly experienced in audio systems like hearing aids or public address systems. Acoustic feedback occurs when the sound from the loudspeaker is picked up by the microphone and re-amplified repeatedly, causing annoyance and reducing sound quality.

## 2 Project Description

Acoustic feedback is a major challenge, especially in compact devices like hearing aids where the microphone and loudspeaker are close to each other. Effectively canceling this feedback improves sound clarity and increases the maximum stable gain the system can achieve without howling.

We use a technique called **Adaptive Feedback Cancellation (AFC)**. Specifically, this project implements the **Prediction Error Method (PEM)**. The main idea is to use adaptive filters to estimate the acoustic feedback path from the loudspeaker to the microphone. This estimated feedback signal is then subtracted from the microphone signal, thereby removing or significantly reducing the feedback component. To reduce bias in the feedback path estimation (due to the correlation between the loudspeaker signal and the input signal), PEM uses pre-whitening filters to whiten the inputs of the adaptive filter.

The specific adaptive algorithms explored include NLMS (Normalized Least Mean Squares), PNLMS (Proportionate NLMS), and IPNLMS (Improved PNLMS) with l0-norm and l1-norm. These algorithms automatically adjust the filter coefficients based on an error signal to optimize feedback cancellation.

## 3 Technologies Used

* **Programming Language:** MATLAB
* **Core Method:** Prediction Error Method (PEM) for Adaptive Feedback Cancellation (AFC)
* **Adaptive Algorithms:**
    * Normalized Least Mean Squares (NLMS)
    * Proportionate NLMS (PNLMS)
    * Improved PNLMS (IPNLMS) l0-norm
    * Improved PNLMS (IPNLMS) l1-norm
    * (Includes helper functions like `DelaySample.m` for creating delays and `FilterSample.m` for signal filtering)

## 4 User Manual

To run the simulations and evaluate the AFC algorithms:

1.  **Open MATLAB.**
2.  **Set Path:** Ensure all necessary `.m` files (`PEM_TDfeedback_Modified1.m`, `PemAFC_Modified.m`, `PemAFCinit.m`, `DelaySample.m`, `FilterSample.m`) and data files (e.g., `mFBPathIRs16kHz_FF.mat`, `mFBPathIRs16kHz_PhoneNear.mat`, `HeadMid2_Speech_Vol095_0dgs_m1.mat`) are in MATLAB's working directory or added to the path using the `addpath` command.
3.  **Open `PEM_TDfeedback_Modified1.m`**. This is the main script for running the example.
4.  **Customize Parameters (If needed):**
    * `prob_sig`: Select whether to use a probe signal (0: no, 1: yes).
    * `in_sig`: Select the type of input signal (0: white noise, 1: speech-weighted noise, 2: real speech, 3: music).
    * `fs`: Sampling frequency (e.g., 16000 Hz).
    * `N`: Total number of samples.
    * `Kdb`: Gain of the forward path in dB.
    * `d_k`: Delay of the forward path in samples.
    * `d_fb`: Delay of the feedback cancellation path in samples.
    * `Lg_hat`: Full length of the adaptive filter.
    * `SNR`: Signal-to-Noise Ratio (if a probe signal is used).
    * `mu`: Fixed step size for the NLMS algorithm (and base variants).
    * In the `PemAFC_Modified.m` file, the `sel` variable is used to select the specific adaptive algorithm:
        * `sel = 1`: IPNLMS-l1
        * `sel = 2`: IPNLMS-l0
        * `sel = 3`: PNLMS
        * `sel = 4`: NLMS
        You need to change the value of the `sel` variable in the call to `PemAFC_Modified` function inside the loop of `PEM_TDfeedback_Modified1.m` to select the desired algorithm. For example, to use PNLMS (sel=3):
        `[e_delay(k+d_k),AF,AR] = PemAFC_Modified(m(k),y_delayfb(k) , AF , AR , 1 , 3 );`
5.  **Run the Script:** Execute `PEM_TDfeedback_Modified1.m`.
6.  **Observe Results:** Plots for Normalized Misalignment (MIS) and Added Stable Gain (ASG) will be generated to evaluate the algorithm's performance. Average values will also be displayed.

**Notes:**
* The feedback path (`g`) can be changed mid-simulation (e.g., from `g` to `gc` at `N/2`) to test the tracking capability of the algorithms.
* The `PemAFCinit.m` function is used to initialize the data structures for the adaptive filter (AF) and the auto-regressive model (AR).

## 5 How to Contribute

We welcome contributions to improve this project! If you have ideas, bug fixes, or want to add new features, please:

1.  **Fork** this repository.
2.  Create a new **branch** for your changes (`git checkout -b feature/new-feature-name`).
3.  **Commit** your changes (`git commit -am 'Add feature X'`).
4.  **Push** to your branch (`git push origin feature/new-feature-name`).
5.  Create a new **Pull Request**.

Please ensure your code adheres to the existing style and includes appropriate tests (if applicable).

---

# Loại Bỏ Phản Hồi Âm Thanh Bằng Phương Pháp Dự Đoán Lỗi (PEM-AFC)

## 1 Tên Dự Án

Loại Bỏ Phản Hồi Âm Thanh Bằng Phương Pháp Dự Đoán Lỗi

Dự án này tập trung vào việc giải quyết vấn đề phản hồi âm thanh (tiếng hú, tiếng rít) thường gặp trong các hệ thống âm thanh như máy trợ thính hoặc hệ thống âm thanh công cộng. Phản hồi âm thanh xảy ra khi âm thanh từ loa bị micro thu lại và khuếch đại lặp đi lặp lại, gây khó chịu và làm giảm chất lượng âm thanh.

## 2 Mô Tả Dự Án

Phản hồi âm thanh là một thách thức lớn, đặc biệt trong các thiết bị nhỏ gọn như máy trợ thính, nơi micro và loa đặt gần nhau. Việc loại bỏ hiệu quả phản hồi này giúp cải thiện độ rõ của âm thanh và tăng độ khuếch đại ổn định tối đa mà hệ thống có thể đạt được mà không gây ra tiếng hú.

Chúng tôi sử dụng kỹ thuật **Loại Bỏ Phản Hồi Âm Thanh Thích Nghi (Adaptive Feedback Cancellation - AFC)**. Cụ thể, dự án này triển khai **Phương Pháp Dự Đoán Lỗi (Prediction Error Method - PEM)**. Ý tưởng chính là sử dụng các bộ lọc thích nghi để ước tính đường truyền phản hồi âm thanh từ loa đến micro. Sau đó, tín hiệu phản hồi ước tính này sẽ được trừ đi khỏi tín hiệu micro, qua đó loại bỏ hoặc giảm thiểu đáng kể thành phần phản hồi. Để giảm sai lệch trong ước tính đường phản hồi (do sự tương quan giữa tín hiệu loa và tín hiệu đầu vào), phương pháp PEM sử dụng các bộ tiền lọc (pre-whitening filters) để làm trắng tín hiệu đầu vào của bộ lọc thích nghi.

Các thuật toán thích nghi cụ thể được khám phá bao gồm NLMS (Normalized Least Mean Squares), PNLMS (Proportionate NLMS) và IPNLMS (Improved PNLMS) với l0-norm và l1-norm. Các thuật toán này điều chỉnh các hệ số của bộ lọc một cách tự động dựa trên tín hiệu lỗi để tối ưu hóa việc loại bỏ phản hồi.

## 3 Công nghệ Sử dụng

* **Ngôn ngữ lập trình:** MATLAB
* **Phương pháp chính:** Prediction Error Method (PEM) for Adaptive Feedback Cancellation (AFC)
* **Thuật toán thích nghi:**
    * Normalized Least Mean Squares (NLMS)
    * Proportionate NLMS (PNLMS)
    * Improved PNLMS (IPNLMS) l0-norm
    * Improved PNLMS (IPNLMS) l1-norm
    * (Bao gồm các hàm hỗ trợ như `DelaySample.m` để tạo trễ và `FilterSample.m` để lọc tín hiệu)

## 4 Hướng dẫn Sử dụng

Để chạy mô phỏng và đánh giá các thuật toán AFC:

1.  **Mở MATLAB.**
2.  **Thiết lập đường dẫn:** Đảm bảo tất cả các tệp `.m` cần thiết (`PEM_TDfeedback_Modified1.m`, `PemAFC_Modified.m`, `PemAFCinit.m`, `DelaySample.m`, `FilterSample.m`) và các tệp dữ liệu (ví dụ: `mFBPathIRs16kHz_FF.mat`, `mFBPathIRs16kHz_PhoneNear.mat`, `HeadMid2_Speech_Vol095_0dgs_m1.mat`) nằm trong đường dẫn làm việc của MATLAB hoặc đã được thêm vào đường dẫn bằng lệnh `addpath`.
3.  **Mở tệp `PEM_TDfeedback_Modified1.m`**. Đây là tệp chính để chạy ví dụ.
4.  **Tùy chỉnh Tham số (Nếu cần):**
    * `prob_sig`: Chọn có sử dụng tín hiệu thăm dò hay không (0: không, 1: có).
    * `in_sig`: Chọn loại tín hiệu đầu vào (0: nhiễu trắng, 1: nhiễu trọng số tiếng nói, 2: tiếng nói thực, 3: âm nhạc).
    * `fs`: Tần số lấy mẫu (ví dụ: 16000 Hz).
    * `N`: Tổng số mẫu tín hiệu.
    * `Kdb`: Độ lợi của đường truyền thẳng (forward path) tính bằng dB.
    * `d_k`: Trễ của đường truyền thẳng tính bằng mẫu.
    * `d_fb`: Trễ của đường loại bỏ phản hồi tính bằng mẫu.
    * `Lg_hat`: Độ dài đầy đủ của bộ lọc thích nghi.
    * `SNR`: Tỷ số tín hiệu trên nhiễu (nếu có tín hiệu thăm dò).
    * `mu`: Kích thước bước cố định cho thuật toán NLMS (và các biến thể cơ sở).
    * Trong tệp `PemAFC_Modified.m`, biến `sel` được dùng để chọn thuật toán thích nghi cụ thể:
        * `sel = 1`: IPNLMS-l1
        * `sel = 2`: IPNLMS-l0
        * `sel = 3`: PNLMS
        * `sel = 4`: NLMS
        Bạn cần thay đổi giá trị của biến `sel` trong lệnh gọi hàm `PemAFC_Modified` bên trong vòng lặp của `PEM_TDfeedback_Modified1.m` để chọn thuật toán mong muốn. Ví dụ, để sử dụng PNLMS (sel=3):
        `[e_delay(k+d_k),AF,AR] = PemAFC_Modified(m(k),y_delayfb(k) , AF , AR , 1 , 3 );`
5.  **Chạy Script:** Thực thi tệp `PEM_TDfeedback_Modified1.m`.
6.  **Quan sát Kết quả:** Các đồ thị về Sai số chuẩn hóa (MIS), Độ lợi ổn định gia tăng (ASG) sẽ được vẽ để đánh giá hiệu năng của thuật toán. Các giá trị trung bình cũng sẽ được hiển thị.

**Lưu ý:**
* Đường truyền phản hồi (`g`) có thể được thay đổi giữa chừng mô phỏng (ví dụ, từ `g` sang `gc` tại `N/2`) để kiểm tra khả năng bám theo sự thay đổi của thuật toán.
* Các hàm `PemAFCinit.m` được sử dụng để khởi tạo các cấu trúc dữ liệu cho bộ lọc thích nghi (AF) và mô hình tự hồi quy (AR).

## 5 Đóng góp cho Dự án

Chúng tôi luôn chào đón các đóng góp để cải thiện dự án này! Nếu bạn có ý tưởng, sửa lỗi, hoặc muốn thêm tính năng mới, vui lòng:

1.  **Fork** repository này.
2.  Tạo một **branch** mới cho các thay đổi của bạn (`git checkout -b feature/ten-tinh-nang-moi`).
3.  **Commit** các thay đổi (`git commit -am 'Thêm tính năng X'`).
4.  **Push** lên branch của bạn (`git push origin feature/ten-tinh-nang-moi`).
5.  Tạo một **Pull Request** mới.

Vui lòng đảm bảo rằng code của bạn tuân theo phong cách hiện có và bao gồm các bài kiểm tra phù hợp (nếu có thể).

---
