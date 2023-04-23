def stopword():
  import pythainlp
  
  stopword = pythainlp.corpus.common.thai_stopwords()
  stopword = list(stopword)
  return stopword
