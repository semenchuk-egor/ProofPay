import logging
import sys
from datetime import datetime

def setup_logger(name: str, level=logging.INFO):
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(level)
        
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    
    return logger

# Application loggers
app_logger = setup_logger('proofpay')
api_logger = setup_logger('proofpay.api')
db_logger = setup_logger('proofpay.db')
blockchain_logger = setup_logger('proofpay.blockchain')
