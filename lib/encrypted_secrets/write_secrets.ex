defmodule EncryptedSecrets.WriteSecrets do
  @moduledoc """
    Provides a method for reading a file then writing it as an encrypted string
  """

  alias EncryptedSecrets.Encryption, as: Encryption

  @doc """
    Reads the contents of `input_path`, encrypts it using `key`,
     and writes it to `output_path`

    Returns `{:ok, filepath} | {:error, message}`
  """
  def write_file(key, input_path, output_path) do
    read_input_file(input_path)
    |> encrypt_message(key)
    |> write_encrypted_file(output_path)
  rescue
    e in RuntimeError -> {:error, e.message}
    e in ArgumentError -> {:error, e.message}
  end

  @doc """
    Writes an encrypted blank file to `output_path` using `key`.
     Used for first time setup

    Returns `{:ok, filepath} | {:error, message}`
  """
  def write_blank_file(key, output_path) do
    encrypt_message("", key)
    |> write_encrypted_file(output_path)
  rescue
    e in RuntimeError -> {:error, e.message}
    e in ArgumentError -> {:error, e.message}
  end

  defp read_input_file(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> contents
      {:error, err} -> raise("Error reading '#{input_path}' (#{err})")
    end
  end

  defp encrypt_message(input_text, key) do
    {:ok, {init_vec, cipher_text}} =
      String.trim(key)
      |> Base.decode16!()
      |> Encryption.encrypt(input_text)

    {Base.encode16(init_vec), Base.encode16(cipher_text)}
  end

  defp write_encrypted_file({init_vec, cipher_text}, output_path) do
    encrypted_string = "#{init_vec}|#{cipher_text}"

    case File.write(output_path, encrypted_string) do
      :ok -> {:ok, output_path}
      {:error, err} -> {:error, "Error writing secrets to '#{output_path}' (#{err})"}
    end
  end
end
