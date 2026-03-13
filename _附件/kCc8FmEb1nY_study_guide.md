# Building GPT from Scratch: A Comprehensive Study Guide

This study guide provides a detailed synthesis of the principles, architectural components, and training methodologies involved in creating a Generative Pre-trained Transformer (GPT). It is based on the technical breakdown of building a character-level language model using the Transformer architecture.

---

## Core Concepts

### 1. The Nature of Language Models
A language model is a system that models the sequence of words, characters, or tokens. Its primary function is **sequence completion**: given a specific prefix (prompt), the model predicts the most likely subsequent elements based on patterns learned during training. These systems are **probabilistic**, meaning they can produce multiple different outputs for the exact same prompt.

### 2. The Transformer Architecture
The Transformer is the neural network architecture that performs the "heavy lifting" for modern AI like ChatGPT.
*   **Origin:** Proposed in the 2017 landmark paper *"Attention is All You Need."*
*   **GPT Definition:** GPT stands for **Generatively Pre-trained Transformer**.
*   **Evolution:** Originally designed for machine translation, the architecture was later "copy-pasted" into various AI applications due to its efficiency and scalability.

### 3. Data and Tokenization
Before text can be processed by a neural network, it must be converted into numbers.
*   **Tokenization:** The process of translating raw text (strings) into a sequence of integers according to a vocabulary.
*   **Granularity Levels:**
    *   **Character-level:** Translating individual characters into integers (simplest, creates long sequences).
    *   **Subword-level:** Using units like "SentencePiece" or "Byte Pair Encoding" (BPE). This is what GPT uses in practice (e.g., OpenAI’s `tiktoken` library).
*   **Tiny Shakespeare:** A toy dataset consisting of roughly 1 million characters from the works of Shakespeare, used to train smaller-scale "nano" models.

### 4. The Self-Attention Mechanism
Self-attention is a communication mechanism that allows different positions (nodes) in a sequence to "talk" to each other to share information.
*   **Query (Q):** "What am I looking for?"
*   **Key (K):** "What do I contain?"
*   **Value (V):** "If you find me interesting, here is what I will communicate to you."
*   **The Affinity Calculation:** The interaction between nodes is determined by the dot product of the Query and the Key. If they align, the affinity is high, and more of that node's Value is aggregated into the current position.
*   **Scaled Dot-Product Attention:** Dividing the dot product by the square root of the head size ($\sqrt{d_k}$) to control variance at initialization and prevent the Softmax function from becoming too "peaky."

### 5. Architectural Innovations for Depth
As neural networks become deeper, they become harder to optimize. Three key techniques facilitate the training of deep Transformers:
*   **Residual (Skip) Connections:** A "gradient superhighway" that allows gradients to flow unimpeded from the output to the input by adding the result of a transformation back to its input ($x + \text{Attention}(x)$).
*   **Layer Normalization (LayerNorm):** A technique to normalize the features of each token, ensuring they have unit mean and unit variance, which stabilizes the optimization process.
*   **Dropout:** A regularization technique where a random subset of neurons is disabled during each forward pass to prevent overfitting and encourage the network to learn redundant representations.

---

## Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **Batch Size** | The number of independent sequences processed in parallel during a single forward/backward pass. |
| **Block Size** | Also known as context length; the maximum number of tokens the model can look back at to predict the next token. |
| **Bigram Model** | A simple language model where the prediction of the next token depends only on the identity of the current token. |
| **Cross-Attention** | A variation of attention where Queries come from one source (e.g., a decoder) and Keys/Values come from an external source (e.g., an encoder). |
| **Decoder-Only** | An architecture (like GPT) that uses triangular masking to prevent tokens from "looking into the future," used for generative tasks. |
| **Encoder-Decoder** | An architecture used for translation; the encoder processes the source language (French), and the decoder generates the target language (English). |
| **Hyperparameters** | Configuration settings for the model, such as the number of layers (`n_layer`), embedding dimensions (`n_embd`), and number of heads (`n_head`). |
| **Logits** | The raw, unnormalized scores produced by the neural network for each possible next token in the vocabulary. |
| **Softmax** | A function that turns logits into a probability distribution that sums to one. |

---

## Short-Answer Practice Questions

1.  **Why is a triangular mask (Tril) used in the self-attention of a decoder-only Transformer?**
    *   *Answer:* It ensures that the model cannot "see the future" during training. A token at position $t$ is only allowed to aggregate information from tokens at positions $0$ through $t$.

2.  **What is the difference between "Pre-training" and "Fine-tuning"?**
    *   *Answer:* Pre-training involves training on a massive dataset (like the internet) to make the model a "document completer." Fine-tuning aligns the model to be a helpful assistant by training it on specific instruction-answer pairs and using human feedback.

3.  **In the context of self-attention, what does "no notion of space" mean?**
    *   *Answer:* Attention acts over a set of vectors regardless of their position. Without adding **Positional Encodings**, the model would treat a sequence as a "bag of words" with no understanding of the order of tokens.

4.  **Why do we divide the Query-Key dot product by the square root of the head size?**
    *   *Answer:* To prevent the variance of the scores from becoming too large. If the scores are too high or low, the Softmax function will output "one-hot" vectors, leading to poor gradient flow at initialization.

5.  **What is the role of the Feed-Forward Network (FFN) in a Transformer block?**
    *   *Answer:* While self-attention is for communication between tokens, the FFN allows each token to "think" and process the information it has gathered individually.

---

## Essay Prompts for Deeper Exploration

1.  **The Evolution of Attention:** Discuss how the self-attention mechanism shifted AI development from spatial-based models (like Convolutions) to communication-based models. How does the "Query, Key, Value" system mimic a database retrieval process?

2.  **The Optimization Challenge:** Analyze the necessity of Residual Connections and Layer Normalization in deep learning. How do these components address the mathematical limitations of backpropagation in networks with many layers?

3.  **Alignment and Control:** GPT models are initially trained to simply "complete documents." Explore the multi-step process (Supervised Fine-Tuning, Reward Modeling, and PPO) required to transform a raw Transformer into a conversational AI like ChatGPT. Why is the pre-training stage insufficient for a consumer-facing product?

4.  **Scaling Laws:** Compare the "nano" GPT (10 million parameters, 300,000 tokens) with gpt3-175B (175 billion parameters, 300 billion tokens). What are the infrastructure challenges associated with scaling Transformers to this magnitude, and how does the architecture support this growth?