# Study Guide: Building a Multi-Layer Perceptron (MLP) Character-Level Language Model

This study guide provides a comprehensive overview of the transition from simple bigram language models to more sophisticated Multi-Layer Perceptrons (MLP) for character-level prediction. It is based on the modeling approach proposed by Bengio et al. (2003) and focuses on the architecture, implementation, and optimization of these models.

---

## Key Concepts and Technical Foundations

### 1. The Limitation of Bigram Models
The bigram model predicts the next character based only on the single previous character. While approachable, this method fails to capture longer-range dependencies. Expanding the context window in a count-based model is impractical because the number of possibilities grows exponentially. For a 27-character alphabet:
*   **1 character of context:** 27 possibilities.
*   **2 characters of context:** $27^2 = 729$ possibilities.
*   **3 characters of context:** $27^3 = 19,683$ possibilities.
This "explosion" of possibilities leads to sparse data (too few counts per possibility) and unmanageable matrix sizes.

### 2. The MLP Modeling Approach (Bengio et al. 2003)
The MLP approach addresses the dimensionality problem by associating each token (word or character) with a low-dimensional **feature vector (embedding)**.
*   **Embeddings:** Tokens are mapped into a continuous space (e.g., 2-dimensional or 30-dimensional). Initially random, these vectors are tuned via backpropagation.
*   **Generalization:** Similar tokens (e.g., "a" and "the" or "dog" and "cat") end up in similar locations in the embedding space. This allows the model to generalize to sequences it has never seen in the training data by transferring knowledge through the embedding space.

### 3. Neural Network Architecture
The model typically follows this structure for a context length (block size) of three:
1.  **Input Layer:** Three previous characters represented as integer indices.
2.  **Lookup Table ($C$):** A shared matrix used to retrieve the embedding vector for each input character.
3.  **Hidden Layer:** A fully connected layer that takes the concatenated embeddings as input, applies a linear transformation ($W1, b1$), and follows with a $tanh$ non-linearity.
4.  **Output Layer:** A fully connected layer ($W2, b2$) that produces **logits** for every possible character in the vocabulary (e.g., 27).
5.  **Softmax:** A final layer that exponentiates and normalizes logits to produce a probability distribution that sums to 1.

### 4. Implementation Efficiency in PyTorch
*   **Indexing vs. One-Hot:** While matrix-multiplying a one-hot vector by a weight matrix is mathematically equivalent to plucking a row from a lookup table, direct indexing is significantly faster and more memory-efficient.
*   **The `.view()` Method:** To prepare embeddings for the hidden layer, they must be concatenated. Using `.view()` is preferred over `.cat()` because it does not create new memory; it simply changes the metadata (strides and offset) of how the underlying one-dimensional storage is interpreted.
*   **Cross Entropy:** Using `torch.nn.functional.cross_entropy` is superior to manual implementation because:
    *   **Fused Kernels:** It clusters operations for efficiency.
    *   **Numerical Stability:** It prevents "Not a Number" (NaN) errors by subtracting the maximum logit before exponentiation to avoid overflow.

### 5. Training and Evaluation
*   **Minibatches:** Instead of calculating the gradient for the entire dataset (e.g., 228,000 examples), training is performed on small, random subsets (e.g., 32 examples). This is much faster and provides a "good enough" gradient for optimization.
*   **Data Splits:** To prevent **overfitting** (memorizing the training set), data is split into:
    *   **Training Set (80%):** Used to optimize weights and biases.
    *   **Dev/Validation Set (10%):** Used to tune hyperparameters (hidden layer size, embedding size, learning rate).
    *   **Test Set (10%):** Evaluated very sparingly at the very end to report final performance.

---

## Short-Answer Practice Questions

1.  **Why does a count-based language model fail when the context length increases?**
    The number of possible contexts grows exponentially with the length of the context, leading to an explosion of rows in the count matrix and insufficient data to fill those rows.

2.  **What is the primary benefit of using word or character embeddings?**
    Embeddings allow the model to transfer knowledge between similar tokens. By placing similar characters in a similar part of the embedding space, the model can generalize to novel scenarios not explicitly seen in the training data.

3.  **What is a "hyperparameter" in the context of an MLP?**
    A hyperparameter is a design choice made by the neural network designer, such as the size of the hidden layer, the dimensionality of the embeddings, or the context length (block size).

4.  **Why is it beneficial to use a learning rate decay?**
    As the model nears a local minimum during optimization, a high learning rate may cause it to "overshoot" or thrash. Lowering the learning rate allows for finer, more stable updates at the late stages of training.

5.  **Explain the difference between "underfitting" and "overfitting."**
    Underfitting occurs when the model is too small to capture the patterns in the data (training and dev loss are roughly equal and high). Overfitting occurs when the model is powerful enough to memorize the training data, leading to a very low training loss but a significantly higher dev/test loss.

6.  **What does the `tanh` function do in the hidden layer?**
    It serves as a non-linearity that squashes the output of the linear transformation into a range between -1 and 1.

7.  **How does PyTorch's `cross_entropy` function handle numerical stability?**
    It identifies the maximum value in the logits and subtracts it from all logits in the row. This ensures that the largest value passed to the exponentiation function is zero, preventing overflow to infinity.

---

## Essay Prompts for Deeper Exploration

1.  **The Role of Generalization in Language Modeling:** Discuss how the transition from a discrete count-based model to a continuous embedding-based model changes the way a system "understands" relationships between characters or words. Use the examples of synonyms or interchangeable parts of speech provided in the text.
2.  **Optimization Strategies and Trade-offs:** Compare the use of full-batch gradient descent versus minibatch gradient descent. Why is it acceptable to use an "approximate" gradient in practice, and how does this affect the speed and convergence of the model?
3.  **The Importance of Evaluation Discipline:** Analyze the necessity of the Train/Dev/Test split. Why is it considered "cheating" to evaluate the test set frequently, and how does the Dev set act as a buffer for hyperparameter tuning?
4.  **Identifying Bottlenecks in Model Architecture:** If a model's training and validation losses are nearly identical but still high, the model is underfitting. Discuss the various "knobs" a designer can turn (embedding size, hidden layer size, block size) to improve performance and the potential risks of increasing these values too much.

---

## Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **Backpropagation** | The process used to tune the embeddings, weights, and biases by propagating the loss backward through the network to calculate gradients. |
| **Block Size** | The context length; the number of previous characters used to predict the next one. |
| **Embedding** | A low-dimensional feature vector representing a token in a continuous space. |
| **Logits** | The raw, unnormalized output scores of the final layer of a neural network before they are passed to a softmax function. |
| **Loss Function** | A mathematical measure of how poorly the model is performing; in this context, the negative log-likelihood of the correct character. |
| **Minibatch** | A small, randomly selected subset of the training data used to perform a single update to the model's parameters. |
| **Softmax** | A mathematical operation that converts a vector of logits into a probability distribution where each value is between 0 and 1 and all values sum to 1. |
| **Tanh** | A hyperbolic tangent activation function that introduces non-linearity into the neural network. |
| **Underlying Storage** | The one-dimensional vector in computer memory where PyTorch stores the actual numbers of a tensor, regardless of its dimensional "view." |
| **View** | A PyTorch operation that changes the logical dimensions of a tensor without altering its physical data in memory. |