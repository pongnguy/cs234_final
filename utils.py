from dataclasses import dataclass, field
from typing import Optional

import torch
import tqdm
from transformers import Trainer, TrainerCallback

import psycopg2
from datetime import datetime
import git


class ModifiedTrainer(Trainer):
    # Alfred change the loss function for running training again
    def compute_loss(self, model, inputs, return_outputs=False):
        return model(
            input_ids=inputs["input_ids"],
            attention_mask=torch.ones_like(inputs["input_ids"]).bool(),
            labels=inputs["input_ids"],
        ).loss

class PrinterCallback(TrainerCallback):
    repo = git.Repo(search_parent_directories=True)

    def on_log(self, args, state, control, logs=None, **kwargs):
        _ = logs.pop("total_flos", None)
        if state.is_local_process_zero:
            with open("logs/BLOOM-fine-tune.log", "a") as f:
                sha = self.repo.head.object.hexsha
                logs_add = logs
                logs_add["git-repository"] = self.repo
                logs_add["git-commit"] = sha
                logs_add["date"] = datetime.now()
                f.write(str(logs_add))


class DatabaseCallback(TrainerCallback):
    repo = git.Repo(search_parent_directories=True)

    def __init__(self, *args, host, database, user, password):
        super.__init__(self, *args)
        self.conn_info = {}
        self.conn_info["host"] = host
        self.conn_info["database"] = database
        self.conn_info["user"] = user
        self.conn_info["password"] = password
        self.conn = psycopg2.connect(host=self.conn_info["host"], database=self.conn_info["database"], user=self.conn_info["user"], password=self.conn_info["password"])

    def on_log(self, args, state, control, logs=None, **kwargs):
        _ = logs.pop("total_flos", None)
        if state.is_local_process_zero:
            with self.conn.cursor() as cur:
                cur.execute(f"INSERT INTO logs (date,git-commit,git-repository,rest) VALUES ('{self.repo}','{self.repo.head.object.hexsha}','{datetime.now()}','{logs}')")
                self.conn.commit()

def data_collator(features: list) -> dict:
    return {"input_ids": torch.stack([torch.LongTensor(f) for f in features])}


def tokenise_data(dataset, tokenizer, max_seq_length=512):
    tokenised_list = []
    for elem in tqdm.tqdm(dataset["train"]):
        tokenised_list.append(
            tokenizer.encode(
                elem["text"],
                max_length=max_seq_length,
                padding="max_length",
                truncation=True,
            )
        )
    return tokenised_list


@dataclass
class ModelArguments:
    model_name_or_path: Optional[str] = field(default="bigscience/bloom-560m")


@dataclass
class DataArguments:
    data_name_or_path: str = field(
        default="tatsu-lab/alpaca", metadata={"help": "Path to the training data."}
    )
