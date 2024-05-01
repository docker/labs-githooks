(ns init
  (:require
   [babashka.process :as p]
   [cheshire.core :as json]
   [clj-yaml.core :as yaml]
   [babashka.fs :as fs]
   [selmer.parser :as selmer]))

(def linter-registry
  {:markdownlint {:id "markdownlint"
                  :name "markdown linter"
                  :entry "vonwig/docker-policy"
                  :files "\\.md$"}
   :hadolint {:id "hadolint"
              :name "hadolint Dockerfile linter"
              :entry "hadolint/hadolint"
              :files "Dockerfile"}
   :golangci-lint {:id "golangcli-lint"
                   :name "golang cli"
                   :entry "golangci/golangci-lint"
                   :files "\\.go$"}
   :actionlint {:id "actionlint"
                :entry "rhysd/actionlint"
                :types ["yaml"]
                :files "^.github/workflows/"}})

(def language-registry
  {:Dockerfile :hadolint
   :Nix :none
   :Clojure :none
   :JSON :none
   :Markdown :markdownlint
   :Go :golangci-lint})

(defn languages [host-dir]
  (let [{:keys [out err exit]}
        @(p/process
          {:out :string :err :string :dir host-dir}
          #_(format "docker run -i --rm -v %s:/project crazymax/linguist --json /project" host-dir)
          (format "/app/result/bin/l -json %s" host-dir))]
    (concat
      (->> (json/parse-string out true)
           (map first)
           (into #{})))))

(defn lookup-in-registry [k]
  (when-let [r (k linter-registry)]
    [(assoc r :language "docker_image")]))

(defn pre-commit-config [linters]
  (yaml/generate-string
    {:repos
     (concat
       [{:repo "http://github.com/pre-commit/pre-commit-hooks"
         :rev "v2.3.0"
         :hooks
         [{:id "check-yaml"}
          {:id "trailing-whitespace"}
          {:id "check-merge-conflict"}]}
        {:repo "https://github.com/jorisroovers/gitlint"
         :rev "main"
         :hooks
         [{:id "gitlint"}]}
        {:repo "local"
         :hooks
         (->> linters
              (mapcat lookup-in-registry)
              (into []))}])}))

(defn linters [languages]
  (->> languages
       (map language-registry)
       (filter identity)))

(defn write-pre-commit-config-file [f s]
  (spit (fs/file f "pre-commit-config.yaml") s))

(defn generate-config-file [host-dir]
  ((comp (partial write-pre-commit-config-file host-dir) pre-commit-config linters languages) host-dir))

(defn generate-hooks [host-dir]
  (spit
    (fs/file host-dir ".git/hooks/pre-commit")
    (selmer/render (slurp "resources/pre-commit.template") {}))
  (p/shell "/app/result/bin/chmod" "755" (str (fs/absolutize (fs/file host-dir ".git/hooks/pre-commit"))))
  (spit
    (fs/file host-dir ".git/hooks/commit-msg")
    (selmer/render (slurp "resources/commit-msg.template") {}))
  (p/shell "/app/result/bin/chmod" "755" (str (fs/absolutize (fs/file host-dir ".git/hooks/commit-msg")))))

(def host-dir "/Users/slim/slimslenderslacks/githooks")
(def lsp-dir "/Users/slim/docker/lsp")
(def pod-dir "/Users/slim/docker/babashka-pod-docker/")

(defn -main []
  (println "setup hooks in /project mount")
  (generate-config-file "/project")
  (generate-hooks "/project"))

(-main)

(comment
  (languages host-dir)
  (languages lsp-dir)
  (languages pod-dir)
  (println (generate-config-file host-dir))
  (generate-hooks host-dir)
  )

