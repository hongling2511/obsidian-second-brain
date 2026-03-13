# Study Guide: Reproducing GPT-2 (124M)

This study guide provides a comprehensive overview of the technical architecture, optimization strategies, and hardware considerations involved in reproducing the GPT-2 124M parameter model, as outlined in the provided technical analysis.

## Key Concepts and Technical Architecture

### 1. Model Specifications (GPT-2 124M)
The "124M" version is the smallest in the GPT-2 miniseries. While the original OpenAI paper occasionally refers to it as 117M due to a parameter counting error, the actual model contains 124 million parameters.
*   **Layers:** 12
*   **Dimensions/Channels:** 768
*   **Context Length (Block Size):** 1024 tokens
*   **Vocabulary Size:** 50,257 tokens (often optimized to 50,304 for computational efficiency).

### 2. Architectural Modifications
GPT-2 is a **decoder-only** Transformer, differing from the original "Attention is All You Need" architecture by removing the encoder and the cross-attention layers.
*   **Layer Normalization (Pre-Norm):** Unlike the original Transformer, GPT-2 places LayerNorm before the attention and MLP blocks. An additional LayerNorm is added after the final self-attention block before the classifier.
*   **Weight Tying:** The model shares the same weight matrix between the token embedding layer (bottom) and the language modeling head (top). This reduces the parameter count by approximately 30% (saving ~40M parameters).
*   **Positional Embeddings:** GPT-2 uses learned positional embeddings rather than fixed sinusoidal encodings.
*   **GELU Activation:** The model uses the "Approximate" version of the Gaussian Error Linear Unit (GELU) nonlinearity, which was historically favored because the exact error function (erf) was slow in early software frameworks.

### 3. Training and Optimization Strategies
*   **Optimizer:** AdamW is used with specific hyperparameters: $\beta_1 = 0.9$, $\beta_2 = 0.95$, and $\epsilon = 10^{-8}$.
*   **Learning Rate Scheduler:** A cosine decay schedule with a linear warmup. For the 124M model, the max learning rate is typically $6 \times 10^{-4}$, decaying to 10% of its peak.
*   **Gradient Clipping:** The global norm of the gradient is clipped at 1.0 to prevent shocks to the optimization process.
*   **Weight Decay:** A value of 0.1 is applied specifically to 2D parameters (weights and embeddings), while 1D parameters (biases and LayerNorm scales) are excluded from decay.

### 4. Hardware Efficiency and Precision
To accelerate training from a baseline of ~1000ms/step to under 100ms/step, several modern techniques are employed:
*   **Mixed Precision (TF32 and BFloat16):**
    *   **TF32:** Truncates 13 bits of the mantissa internally in the GPU tensor cores to provide an 8x theoretical speedup over FP32 without changing the code.
    *   **BFloat16:** Uses 16 bits but maintains the same exponent range as FP32, preventing the need for gradient scalers required by standard FP16.
*   **Flash Attention 2:** An algorithmic rewrite of the attention mechanism that minimizes memory reads/writes to the GPU's High Bandwidth Memory (HBM) by performing calculations on the chip.
*   **Kernel Fusion:** Utilizing `torch.compile` to fuse multiple element-wise operations into a single GPU kernel, reducing "round trips" to memory.
*   **Distributed Data Parallel (DDP):** Scaling training across multiple GPUs by averaging gradients across processes.

---

## Short-Answer Practice Questions

1.  **Why is the vocabulary size sometimes increased from 50,257 to 50,304?**
    50,304 is a "nice" number (divisible by powers of 2 up to 128), which aligns better with GPU block tiles and avoids inefficient boundary kernels, leading to a slight increase in computational speed.
2.  **What is the purpose of Gradient Accumulation?**
    It allows the simulation of a large batch size (e.g., 0.5 million tokens) that cannot fit into a single GPU's memory by running several smaller "micro-batches" serially and adding their gradients before performing an optimizer update.
3.  **In a Distributed Data Parallel (DDP) setup, what does the "Master Process" (Rank 0) typically handle?**
    The Master Process handles administrative tasks such as logging, checkpointing the model, and printing progress updates to the console.
4.  **What is the difference between learned and fixed positional embeddings?**
    Fixed embeddings use pre-calculated sinusoids/cosines. Learned embeddings (used in GPT-2) are initialized randomly and optimized through training to represent token positions.
5.  **What is the primary benefit of the BFloat16 format over standard Float16?**
    BFloat16 maintains the same exponent range as Float32, which means it can represent the same range of numbers and does not require a gradient scaler to prevent underflow during training.
6.  **How does weight tying regularize the model?**
    It forces the model to use the same representation for tokens at both the input (embedding) and output (prediction), leveraging the inductive bias that semantically similar tokens should behave similarly in both positions.

---

## Essay Prompts for Deeper Exploration

1.  **The Memory Wall vs. Compute Power:** Discuss the concept of a "memory-bound" workload in the context of GPT training. Explain why doubling the theoretical Teraflops of a GPU (through lower precision) does not necessarily double the training speed, and evaluate how techniques like Flash Attention address this bottleneck.
2.  **The Evolution of the Transformer Architecture:** Analyze the specific changes made from the original "Attention is All You Need" Transformer to the GPT-2 decoder-only model. Why were the Layer Normalization steps moved, and what impact does this have on the "clean residual stream"?
3.  **Data Quality vs. Quantity:** Based on the training results on the "Fine Web EDU" dataset, compare the efficiency of modern curated datasets to earlier datasets like GPT-2's "WebText." How did the reproduction achieve GPT-2 level accuracy with significantly fewer tokens?
4.  **The Role of Reproducibility in AI:** Andrej Karpathy notes that OpenAI released weights and papers, but the papers were sometimes vague or contained errors. Discuss the challenges of reproducing state-of-the-art models from academic papers alone and the importance of open-source "reference code."

---

## Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **AdamW** | A version of the Adam optimizer that decouples weight decay from the gradient update to improve regularization. |
| **BFloat16** | A 16-bit floating-point format that sacrifices precision (mantissa) to maintain range (exponent), ideal for deep learning. |
| **Cosine Decay** | A learning rate schedule where the rate follows a cosine curve, starting high and ending at 10% of the peak value. |
| **DDP** | **Distributed Data Parallel**; a PyTorch multi-processing strategy where each GPU holds a copy of the model and synchronizes gradients. |
| **Flash Attention** | An optimized attention algorithm that avoids materializing the large $N \times N$ attention matrix in memory. |
| **GELU** | **Gaussian Error Linear Unit**; a smooth activation function used in GPT models as an alternative to ReLU. |
| **HellaSwag** | A common-sense reasoning benchmark that asks models to predict the most likely completion of a sentence in a multiple-choice format. |
| **High Bandwidth Memory (HBM)** | The primary memory on a GPU (e.g., 80GB on an A100) that is off-chip but faster than system RAM. |
| **Kernel Fusion** | The process of combining multiple mathematical operations into a single GPU instruction to minimize memory access. |
| **Mixed Precision** | The practice of using different numerical formats (e.g., FP32, BF16) for different parts of a model to balance speed and accuracy. |
| **Residual Stream** | The central pathway in a Transformer where inputs are added to the outputs of sub-layers, allowing gradients to flow more easily. |
| **TF32** | **Tensor Float 32**; an internal GPU format that provides the speed of lower precision while maintaining the interface of FP32. |
| **Tiktoken** | A fast BPE (Byte Pair Encoding) tokenizer used by OpenAI for GPT models. |
| **Weight Tying** | A memory-saving technique where the input embedding and output projection layers share the same weights. |