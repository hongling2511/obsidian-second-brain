# Study Guide: Building a WaveNet-Inspired Language Model

This study guide provides a comprehensive overview of the architectural evolution from a simple Multi-Layer Perceptron (MLP) to a hierarchical, WaveNet-inspired character-level language model. It covers technical implementations, the "Pytorchification" of code, and critical debugging processes for deep learning layers.

---

## Key Concepts and Technical Summary

### 1. From MLP to WaveNet Architecture
The previous iteration of the "makemore" model used a simple MLP architecture where a fixed number of context characters (e.g., 3) were embedded and immediately crushed into a single hidden layer. This approach is limited because it squashes information too quickly. 

The WaveNet-inspired approach introduces **hierarchical fusion**:
*   **Context Extension:** Increasing the block size (context length) from 3 to 8 characters.
*   **Progressive Fusion:** Instead of feeding all 8 characters into one layer, characters are fused in pairs to create bigram representations, then 4-character representations, and so on. This creates a tree-like structure that processes information slowly as the network gets deeper.
*   **Auto-regressive Nature:** Like audio-based WaveNet, this character-level model predicts the next element in a sequence based on previous elements.

### 2. "Pytorchifying" the Codebase
To align the custom implementation with industry standards like `torch.nn`, several modular changes were made:
*   **Embedding Layer:** A dedicated module that wraps the embedding table lookup, allowing it to be treated as a standard layer in the stack.
*   **Flattening Layer:** A custom `FlattenConsecutive` module replaces the manual "view" operations. It allows for concatenating specific numbers of consecutive elements (e.g., fusing two 10-dimensional embeddings into one 20-dimensional vector).
*   **Sequential Container:** A new `Sequential` class organizes layers into a list, handling the forward pass and parameter management automatically. This replaces manual "naked" lists of layers.

### 3. High-Dimensional Matrix Multiplication
A critical insight in implementing hierarchical layers is that the PyTorch matrix multiplication operator (`@`) is highly flexible. It performs the operation on the last dimension of a tensor while treating all preceding dimensions as batch dimensions. 
*   **Example:** A linear layer with an input of shape `(4, 4, 20)` and a weight matrix of `(20, 200)` will output a shape of `(4, 4, 200)`. This allows the model to process groups of characters in parallel across multiple "batch" dimensions.

### 4. Correcting Batch Normalization for 3D Tensors
Batch Normalization (BatchNorm) originally designed for 2D inputs (Batch, Features) must be adjusted for 3D inputs (Batch, Sequence, Features):
*   **The Bug:** If BatchNorm only reduces across the 0th dimension on a 3D tensor, it maintains separate statistics for every position in the sequence, which is unstable and incorrect for this architecture.
*   **The Fix:** The mean and variance must be calculated across both the 0th and 1st dimensions (Batch and Sequence) to ensure statistics are shared across all positions for each channel. This results in more stable estimates (e.g., using $32 \times 4$ samples instead of just 32).

---

## Short-Answer Practice Questions

1.  **Why is "squashing" all input characters into a single hidden layer considered a limitation as context length increases?**
    It compresses the information too rapidly, losing the nuances of how characters relate to each other in sequence before the network has a chance to process them deeply.

2.  **What is the primary function of the `FlattenConsecutive` layer in a hierarchical model?**
    It rearranges the tensor to concatenate a specific number of consecutive character embeddings into the last dimension, facilitating the "fusion" of information (e.g., turning eight 10D vectors into four 20D vectors).

3.  **In the context of Batch Normalization, why is "state" (like running mean and variance) considered potentially harmful?**
    State introduces complexity and bugs, particularly when the layer behaves differently during training versus evaluation. Forgetting to toggle the `training` flag can lead to incorrect predictions based on sample statistics rather than running averages.

4.  **How does the implementation of a hierarchical model change the number of parameters compared to a flat MLP?**
    While the architecture changes, the parameter count can be kept similar by adjusting the number of hidden units (channels). The goal is to see if the hierarchical *arrangement* of those parameters is more efficient at processing information.

5.  **What is the role of the `torch.squeeze` function in the custom `FlattenConsecutive` module?**
    It removes spurious dimensions of size 1 that may occur when the flattening operation results in a single output group, ensuring the output remains a 2D tensor when expected.

6.  **Why are convolutions mentioned as an implementation detail for WaveNet?**
    Convolutions allow the model to be "slid" over an input sequence efficiently. They hide the necessary for-loops inside optimized CUDA kernels and allow for variable reuse, making the process much faster than manual iterative calls.

---

## Essay Prompts for Deeper Exploration

1.  **The Evolution of Experimental Harnesses:** The source context notes that current development is "in the dark" due to a lack of an experimental harness. Design a proposal for a robust deep learning workflow. What metrics should be tracked, what hyper-parameters should be tunable via arguments, and why is it critical to observe both training and validation loss simultaneously?

2.  **Architectural vs. Computational Efficiency:** Analyze the distinction between the tree-like hierarchical structure implemented in this model and the use of Dilated Causal Convolutions. How do these two concepts relate to each other, and why does the transcript claim that convolutions are an "efficiency" tool rather than a change to the fundamental modeling setup?

3.  **The Pitfalls of Batch Normalization in Complex Architectures:** Discuss the specific challenges encountered when Batch Normalization is applied to 3D tensors. How does the concept of "broadcasting" facilitate both the operation and the potential for silent bugs? Evaluate the decision to deviate from the standard PyTorch `BatchNorm1d` API regarding dimension ordering (NLC vs. NCL).

---

## Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **Auto-regressive** | A modeling setup where the model predicts the next element in a sequence based solely on the preceding elements. |
| **Batch Normalization** | A layer that controls the statistics of activations by normalizing them to have a specific mean and variance, often used to stabilize training. |
| **Block Size** | The number of context characters used to predict the next character; also known as the context length. |
| **Broadcasting** | A PyTorch/NumPy mechanism that allows operations between tensors of different shapes by automatically "expanding" the smaller tensor. |
| **Causal Convolution** | A convolution where the output at a specific time step only depends on current and past inputs, never future ones. |
| **Dilated Convolution** | A convolution where the filter is applied over an area larger than its size by skipping input values with a certain step (dilation). |
| **Embedding Table** | A lookup table (matrix) where each character index is mapped to a high-dimensional continuous vector. |
| **Hierarchical Fusion** | The process of progressively combining information from lower-level inputs (like characters) into higher-level representations (like bigrams or quadgrams). |
| **Logits** | The raw, unnormalized output scores of a neural network before they are passed through a softmax function to become probabilities. |
| **Sequential** | A container module that wraps a list of layers and feeds the output of one layer into the input of the next in order. |
| **Squeeze** | A tensor operation that removes dimensions of size 1 from a tensor's shape. |
| **WaveNet** | A deep generative model for raw audio (DeepMind, 2016) that uses a hierarchical, dilated convolutional architecture. |